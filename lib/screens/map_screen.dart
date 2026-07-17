import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../providers/auth_provider.dart';
import '../models/company_charger.dart';
import '../theme/colors.dart';
import 'location_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  CompanyCharger? _selectedCharger;
  final Set<Marker> _markers = {};
  String? _mapStyle;
  bool _loadingChargers = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-34.60376, -58.38162),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    final json = await rootBundle.loadString('lib/data/map_style.json');
    if (mounted) {
      setState(() => _mapStyle = json);
      _fetchChargers(
        _initialPosition.target.latitude,
        _initialPosition.target.longitude,
      );
    }
  }

  Future<void> _fetchChargers(double lat, double lng) async {
    final auth = context.read<AuthProvider>();
    final api = context.read<ApiClient>();
    try {
      final chargers = await api.companyChargerApi.getClosest(
        lat: lat,
        lng: lng,
        showPublic: true,
        user: auth.userRef,
      );
      if (!mounted) return;

      final markers = <Marker>{};
      for (final charger in chargers) {
        final marker = Marker(
          markerId: MarkerId(charger.self),
          position: LatLng(charger.lat, charger.lng),
          icon: await _createPinMarker(charger.status),
          anchor: const Offset(0.5, 1.0),
          onTap: () {
            setState(() => _selectedCharger = charger);
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(charger.lat - 0.0015, charger.lng),
                  zoom: 16.0,
                ),
              ),
            );
          },
        );
        markers.add(marker);
      }

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
        _loadingChargers = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingChargers = false);
    }
  }

  Future<BitmapDescriptor> _createPinMarker(ChargerStatus status) async {
    final color = _statusColor(status);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 64.0;
    const height = 80.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final pinPath = Path();
    pinPath.moveTo(width / 2, height - 8);
    pinPath.quadraticBezierTo(width / 2 + 18, height - 28, width / 2 + 20, height - 48);
    pinPath.quadraticBezierTo(width / 2 + 22, height - 72, width / 2, height - 76);
    pinPath.quadraticBezierTo(width / 2 - 22, height - 72, width / 2 - 20, height - 48);
    pinPath.quadraticBezierTo(width / 2 - 18, height - 28, width / 2, height - 8);
    pinPath.close();

    canvas.drawPath(pinPath.shift(const Offset(2, 2)), shadowPaint);

    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width / 2, height - 50), 12, innerCirclePaint);

    final iconPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final boltPath = Path();
    boltPath.moveTo(width / 2 + 1, height - 58);
    boltPath.lineTo(width / 2 - 4, height - 50);
    boltPath.lineTo(width / 2 - 1, height - 50);
    boltPath.lineTo(width / 2 + 1, height - 44);
    boltPath.lineTo(width / 2 - 4, height - 44);
    boltPath.lineTo(width / 2 - 1, height - 50);
    boltPath.close();

    final boltFinal = Path();
    boltFinal.moveTo(width / 2, height - 58);
    boltFinal.lineTo(width / 2 - 4, height - 49);
    boltFinal.lineTo(width / 2 - 1, height - 49);
    boltFinal.lineTo(width / 2 + 1, height - 43);
    boltFinal.lineTo(width / 2 - 3, height - 43);
    boltFinal.lineTo(width / 2, height - 49);
    boltFinal.lineTo(width / 2 + 4, height - 49);
    boltFinal.close();
    canvas.drawPath(boltFinal, iconPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes, width: width, height: height);
  }

  Color _statusColor(ChargerStatus status) {
    switch (status) {
      case ChargerStatus.available:
        return const Color(0xFF4CAF50);
      case ChargerStatus.occupied:
        return const Color(0xFFFF9800);
      case ChargerStatus.unavailable:
        return const Color(0xFFE53935);
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
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            style: _mapStyle,
            onTap: (_) => setState(() => _selectedCharger = null),
            padding: EdgeInsets.only(
              top: topPad + 72,
              bottom: _selectedCharger != null ? 310 : 100,
            ),
          ),

          _buildSearchBar(topPad),

          if (_loadingChargers)
            Positioned(
              top: topPad + 80,
              left: 0,
              right: 0,
              child: const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          if (_selectedCharger != null)
            _ChargerInfoCard(
              charger: _selectedCharger!,
              bottomPad: bottomPad,
              onClose: () => setState(() => _selectedCharger = null),
            ),

          _buildLocationButton(bottomPad),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double topPad) {
    return Positioned(
      top: topPad + 12,
      left: 16,
      right: 16,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(Icons.search, color: Colors.grey.shade500, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Buscar cargador...',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(double bottomPad) {
    return Positioned(
      bottom: _selectedCharger != null ? 310 + bottomPad : 24 + bottomPad,
      right: 16,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _recenterMap,
            borderRadius: BorderRadius.circular(24),
            child: const Icon(
              Icons.my_location,
              color: Color(0xFF555555),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChargerInfoCard extends StatelessWidget {
  final CompanyCharger charger;
  final VoidCallback onClose;
  final double bottomPad;

  const _ChargerInfoCard({
    required this.charger,
    required this.onClose,
    required this.bottomPad,
  });

  void _openLocation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationScreen(charger: charger)),
    );
  }

  Color get _statusColor {
    switch (charger.status) {
      case ChargerStatus.available:
        return const Color(0xFF4CAF50);
      case ChargerStatus.occupied:
        return const Color(0xFFFF9800);
      case ChargerStatus.unavailable:
        return const Color(0xFFE53935);
    }
  }

  Color get _statusBg {
    switch (charger.status) {
      case ChargerStatus.available:
        return const Color(0xFFE8F5E9);
      case ChargerStatus.occupied:
        return const Color(0xFFFFF3E0);
      case ChargerStatus.unavailable:
        return const Color(0xFFFFEBEE);
    }
  }

  String get _statusText {
    switch (charger.status) {
      case ChargerStatus.available:
        return 'Disponible';
      case ChargerStatus.occupied:
        return 'Ocupado';
      case ChargerStatus.unavailable:
        return 'No disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16 + bottomPad,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.ev_station, color: _statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        charger.name,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        charger.serial,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoTag(
                  icon: Icons.bolt,
                  label: '${charger.powerKw} kW',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                _InfoTag(
                  icon: Icons.circle,
                  label: _statusText,
                  color: _statusColor,
                  iconSize: 8,
                ),
                const SizedBox(width: 6),
                _InfoTag(
                  icon: Icons.cable,
                  label: '${charger.connectors.length}',
                  color: const Color(0xFF5C6BC0),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        charger.online ? Icons.wifi : Icons.wifi_off,
                        color: charger.online ? const Color(0xFF4CAF50) : Colors.grey,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        charger.online ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openLocation(context),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, color: Colors.grey.shade700, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Direcciones',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _openLocation(context),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.ev_station, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.color,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
