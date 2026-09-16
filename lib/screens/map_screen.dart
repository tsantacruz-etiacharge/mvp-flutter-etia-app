import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/company_charger.dart';
import '../models/company_location.dart';
import '../models/week_time.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../utils/maps.dart';
import '../utils/week_time.dart';
import '../widgets/app_text.dart';
import '../widgets/connector_info.dart';
import '../widgets/horizontal_separator.dart';

Color _statusColor(ChargerStatus status) {
  switch (status) {
    case ChargerStatus.unavailable:
      return AppColors.highlight;
    case ChargerStatus.available:
      return AppColors.primary;
    case ChargerStatus.occupied:
      return AppColors.warning;
  }
}

class MapScreen extends ConsumerStatefulWidget {
  /// False when another tab is visible (IndexedStack keeps us alive).
  /// Pauses GPS polling and charger fetching while hidden.
  final bool visible;

  const MapScreen({super.key, this.visible = true});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const LatLng _initialCoords = LatLng(-34.60376, -58.38162);

  GoogleMapController? _mapController;
  String? _mapStyle;

  final Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> _iconCache = {};
  BitmapDescriptor? _userIcon;

  List<CompanyCharger> _chargers = const [];
  CompanyCharger? _selectedCharger;
  bool _showCharger = false;

  LatLng _cameraTarget = _initialCoords;
  LatLng? _userLocation;
  bool _programmaticMove = false;
  Timer? _locationTimer;
  Timer? _fetchDebounce;
  CancelToken? _chargersCancel;
  int _fetchSeq = 0;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      _startLiveLocation();
    } else {
      _stopLiveLocation();
    }
  }

  @override
  void dispose() {
    _stopLiveLocation();
    _mapController?.dispose();
    super.dispose();
  }

  void _stopLiveLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _fetchDebounce?.cancel();
    _fetchDebounce = null;
    _chargersCancel?.cancel('hidden');
    _chargersCancel = null;
    _locating = false;
  }

  Future<void> _init() async {
    _mapStyle = await rootBundle.loadString('lib/data/map_style.json');
    _userIcon = await _createUserMarker();
    if (mounted) setState(() {});
    _fetchChargers(_initialCoords);
    _startLiveLocation();
  }

  Future<void> _startLiveLocation() async {
    if (_locating || !widget.visible) return;
    _locating = true;
    try {
      final permission = await Geolocator.checkPermission();
      var granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) {
        final requested = await Geolocator.requestPermission();
        granted = requested == LocationPermission.always ||
            requested == LocationPermission.whileInUse;
      }
      if (!granted || !mounted || !widget.visible) return;

      final first = await _currentPosition();
      if (first != null && mounted) {
        _setUserLocation(first, animate: true);
      }

      _locationTimer?.cancel();
      _locationTimer =
          Timer.periodic(const Duration(seconds: 5), (_) => _updateLocation());
    } finally {
      _locating = false;
    }
  }

  /// Last known first (cheap, may be stale), current fix as fallback.
  /// Prod only reads last-known and can strand the map in Buenos Aires.
  Future<Position?> _currentPosition() async {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return last;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateLocation() async {
    if (!widget.visible) return;
    final position = await _currentPosition();
    if (position != null && mounted) {
      _setUserLocation(position, animate: false);
    }
  }

  void _setUserLocation(Position position, {required bool animate}) {
    final coords = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = coords);
    _rebuildMarkers();
    if (animate) _animateToLocation(coords);
  }

  Future<void> _fetchChargers(LatLng origin) async {
    final auth = ref.read(authProvider);
    final api = ref.read(apiClientProvider);
    final message = ref.read(messageProvider.notifier);
    _chargersCancel?.cancel('superseded');
    final cancel = CancelToken();
    _chargersCancel = cancel;
    final seq = ++_fetchSeq;
    try {
      final chargers = await api.companyChargerApi.getClosest(
        lat: origin.latitude,
        lng: origin.longitude,
        showPublic: true,
        user: auth.userRef,
        cancelToken: cancel,
      );
      if (!mounted || seq != _fetchSeq) return;
      _chargers = chargers.where((c) => c.iconUrl != null).toList();
      await _rebuildMarkers();
    } on DioException catch (e) {
      // Cancelled/superseded fetches and unmounted states stay silent.
      if (e.type == DioExceptionType.cancel || !mounted || seq != _fetchSeq) {
        return;
      }
      message.showError(
        (e.response != null ? 'error.unexpected' : 'error.connection').tr(),
      );
    } catch (_) {
      // Non-Dio errors: silent, same as prod (non-axios -> return).
    }
  }

  Future<void> _rebuildMarkers() async {
    final markers = <Marker>{};

    for (final charger in _chargers) {
      final status = charger.status;
      final icon = await _chargerIcon(charger.iconUrl!, status);
      markers.add(
        Marker(
          markerId: MarkerId(charger.self),
          position: LatLng(charger.lat, charger.lng),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: status == ChargerStatus.available ? 1 : 0,
          onTap: () => _onMarkerTap(charger),
        ),
      );
    }

    if (_userLocation != null && _userIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('__user__'),
          position: _userLocation!,
          icon: _userIcon!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 2,
          consumeTapEvents: false,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
    });
  }

  void _onMarkerTap(CompanyCharger charger) {
    setState(() {
      _selectedCharger = charger;
      _showCharger = true;
    });
    _animateToMarker(LatLng(charger.lat, charger.lng));
  }

  double get _ratio =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  Future<BitmapDescriptor> _chargerIcon(
    String iconUrl,
    ChargerStatus status,
  ) async {
    final key = '$iconUrl|${status.name}';
    final cached = _iconCache[key];
    if (cached != null) return cached;

    final descriptor = await _createChargerMarker(iconUrl, status);
    _iconCache[key] = descriptor;
    return descriptor;
  }

  Future<BitmapDescriptor> _createChargerMarker(
    String iconUrl,
    ChargerStatus status,
  ) async {
    final ratio = _ratio;
    const size = 39.0;
    final dim = size * ratio;
    final border = 2.5 * ratio;
    final padding = 2.0 * ratio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(dim / 2, dim / 2);

    final bg = Paint()..color = AppColors.background;
    canvas.drawCircle(center, dim / 2, bg);

    final ring = Paint()
      ..color = _statusColor(status)
      ..style = PaintingStyle.stroke
      ..strokeWidth = border;
    canvas.drawCircle(center, dim / 2 - border / 2, ring);

    ui.Image? image;
    try {
      image = await _loadNetworkImage(iconUrl);
    } catch (_) {
      image = null;
    }

    if (image != null) {
      final inner = dim - (border + padding) * 2;
      final rect = Rect.fromCenter(center: center, width: inner, height: inner);
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      paintImage(
        canvas: canvas,
        rect: rect,
        image: image,
        fit: BoxFit.contain,
      );
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(dim.toInt(), dim.toInt());
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: ratio,
    );
  }

  Future<BitmapDescriptor> _createUserMarker() async {
    final ratio = _ratio;
    final dim = 24.0 * ratio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(dim / 2, dim / 2);

    final shadow = Paint()..color = AppColors.primary.withValues(alpha: 0.5);
    canvas.drawCircle(center, dim / 2, shadow);

    final dot = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, (14.0 * ratio) / 2, dot);

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(dim.toInt(), dim.toInt());
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: ratio,
    );
  }

  Future<ui.Image> _loadNetworkImage(String url) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _animateToLocation(LatLng coords) {
    _programmaticMove = true;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: coords, zoom: 13),
      ),
    );
  }

  void _animateToMarker(LatLng coords) {
    _programmaticMove = true;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(math.max(coords.latitude - 0.0025, -90), coords.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _initialCoords,
            zoom: 11,
          ),
          style: _mapStyle,
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
          onCameraMove: (position) => _cameraTarget = position.target,
          onCameraMoveStarted: () {
            if (_programmaticMove) return;
            if (_showCharger) setState(() => _showCharger = false);
          },
          onCameraIdle: () {
            // Debounced: every pan/zoom used to fire GET /closest (429 risk).
            _fetchDebounce?.cancel();
            _fetchDebounce = Timer(
              const Duration(milliseconds: 600),
              () {
                _programmaticMove = false;
                if (mounted && widget.visible) _fetchChargers(_cameraTarget);
              },
            );
          },
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.paddingHorizontal,
              right: AppDimensions.paddingHorizontal,
              bottom: AppDimensions.paddingBottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showCharger && _selectedCharger != null)
                  _ChargerCard(
                    key: ValueKey(_selectedCharger!.self),
                    charger: _selectedCharger!,
                    onClose: () => setState(() => _showCharger = false),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: 16,
          child: _IconButton(
            icon: Icons.my_location,
            onPressed: () {
              final location = _userLocation;
              if (location != null) _animateToLocation(location);
            },
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 28, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ChargerCard extends ConsumerStatefulWidget {
  final CompanyCharger charger;
  final VoidCallback onClose;

  const _ChargerCard({
    super.key,
    required this.charger,
    required this.onClose,
  });

  @override
  ConsumerState<_ChargerCard> createState() => _ChargerCardState();
}

class _ChargerCardState extends ConsumerState<_ChargerCard> {
  CompanyLocation? _location;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await ref
          .read(apiClientProvider)
          .referenceApi
          .findByReference(widget.charger.location, CompanyLocation.fromJson);
      if (mounted) setState(() => _location = location);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final charger = widget.charger;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: widget.onClose,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.surface,
                    size: 24,
                  ),
                ),
              ),
            ),
            const HorizontalSeparator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(charger.name, type: AppTextType.subtitle),
                        _OpeningHoursText(
                          openingHours: _location?.openingHours,
                        ),
                      ],
                    ),
                  ),
                  AppText(
                    '${charger.powerKw} kW',
                    type: AppTextType.title,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const HorizontalSeparator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final connector in charger.connectors)
                    ConnectorInfo(
                      online: charger.online,
                      connector: connector,
                      format: ConnectorFormat.small,
                    ),
                ],
              ),
            ),
            const HorizontalSeparator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      onPressed: () => context.push(
                        '/location?locationRef=${Uri.encodeComponent(charger.location)}',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.travel_explore,
                            size: 32,
                            color: AppColors.surface,
                          ),
                          const SizedBox(width: 4),
                          AppText('page.charger.location'.tr()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: _SecondaryButton(
                      onPressed: () =>
                          openMapsTravel(charger.lat, charger.lng),
                      child: const Icon(
                        Icons.directions,
                        size: 32,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _SecondaryButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.highlight, width: 1),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _OpeningHoursText extends StatefulWidget {
  final List<OpeningPeriod>? openingHours;

  const _OpeningHoursText({required this.openingHours});

  @override
  State<_OpeningHoursText> createState() => _OpeningHoursTextState();
}

class _OpeningHoursTextState extends State<_OpeningHoursText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openingHours = widget.openingHours;

    if (openingHours == null) {
      return const AppText(' ', type: AppTextType.hint);
    }

    if (openingHours.isEmpty) {
      return AppText('page.map.open-24hs'.tr(), type: AppTextType.hint);
    }

    final now = DateTime.now();
    final current = openingHours
        .where((period) => isInOpeningHours(now, period))
        .firstOrNull;

    if (current == null) {
      final next = getNextOpeningTime(now, openingHours);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'page.map.closed'.tr(),
            type: AppTextType.hint,
            color: AppColors.error,
          ),
          if (next != null)
            AppText(
              'page.map.opens-at'.tr(
                namedArgs: {
                  'weekday': _weekdayLabel(context, next.weekday),
                  'time': formatWeekTime(next),
                },
              ),
              type: AppTextType.hint,
            ),
        ],
      );
    }

    return AppText(
      'page.map.open'.tr(
        namedArgs: {
          'open': formatWeekTime(current.open),
          'close': formatWeekTime(current.close),
        },
      ),
      type: AppTextType.hint,
    );
  }

  String _weekdayLabel(BuildContext context, int weekday) {
    final target = weekday == 0 ? 7 : weekday;
    final monday = DateTime(2024, 1, 1);
    final date = monday.add(Duration(days: target - 1));
    return DateFormat('EEEE', context.locale.toString()).format(date);
  }
}
