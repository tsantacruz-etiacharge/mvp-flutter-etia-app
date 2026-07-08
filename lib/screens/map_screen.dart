import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/mock_data.dart';
import '../widgets/charger_info_card.dart';
import '../widgets/my_location_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  MockCharger? _selectedCharger;
  final Set<Marker> _markers = {};
  String? _mapStyle;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-34.60376, -58.38162),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _createMarkers();
  }

  Future<void> _loadMapStyle() async {
    final json = await rootBundle.loadString('lib/data/map_style.json');
    if (mounted) setState(() => _mapStyle = json);
  }

  void _createMarkers() {
    for (final charger in mockChargers) {
      final hue = _statusToHue(charger.status);

      _markers.add(
        Marker(
          markerId: MarkerId(charger.id),
          position: charger.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: charger.name,
            snippet: '${charger.powerKw} kW',
          ),
          onTap: () {
            setState(() => _selectedCharger = charger);
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    charger.position.latitude - 0.0025,
                    charger.position.longitude,
                  ),
                  zoom: 15.0,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  double _statusToHue(ChargerStatus status) {
    switch (status) {
      case ChargerStatus.available:
        return BitmapDescriptor.hueGreen;
      case ChargerStatus.occupied:
        return BitmapDescriptor.hueYellow;
      case ChargerStatus.unavailable:
        return BitmapDescriptor.hueAzure;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _recenterMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
    setState(() => _selectedCharger = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            style: _mapStyle,
            onTap: (_) => setState(() => _selectedCharger = null),
          ),
          if (_selectedCharger != null)
            ChargerInfoCard(
              charger: _selectedCharger!,
              onClose: () => setState(() => _selectedCharger = null),
            ),
          MyLocationButton(onPressed: _recenterMap),
        ],
      ),
    );
  }
}
