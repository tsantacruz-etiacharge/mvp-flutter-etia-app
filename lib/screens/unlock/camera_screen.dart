import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../widgets/app_button.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/screen_view.dart';
import '../../widgets/themed_modal.dart';

class CameraUnlockScreen extends StatefulWidget {
  const CameraUnlockScreen({super.key});

  @override
  State<CameraUnlockScreen> createState() => _CameraUnlockScreenState();
}

class _CameraUnlockScreenState extends State<CameraUnlockScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _showAlternative = false;
  bool _flashlight = false;
  bool _handled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _showAlternative = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;

    final parts = raw.split(';');
    final serial = parts[0];
    final connectorID = parts.length > 1 ? parts[1] : '1';

    context.replace(
      '/unlock/charger?serial=${Uri.encodeComponent(serial)}&connectorID=${Uri.encodeComponent(connectorID)}',
    );
  }

  void _toggleFlashlight() {
    _controller.toggleTorch();
    setState(() => _flashlight = !_flashlight);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final frame = width * 0.6;

    return ScreenView(
      backButton: true,
      background: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          final isPermission =
              error.errorCode == MobileScannerErrorCode.permissionDenied;
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.background),
              if (isPermission) _PermissionsModal(controller: _controller),
            ],
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
            child: SizedBox(
              width: frame,
              height: frame,
              child: CustomPaint(painter: _QrFramePainter()),
            ),
          ),
          if (_showAlternative)
            Container(
              margin: const EdgeInsets.only(top: 56),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    'page.unlock.no-qr'.tr(),
                    type: AppTextType.subtitle,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () => context.replace('/unlock/manual'),
                    child: AppText(
                      'page.unlock.enter-serial'.tr(),
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingBottom,
                ),
                child: _IconButton(
                  icon: _flashlight
                      ? Icons.flashlight_on
                      : Icons.flashlight_off,
                  onPressed: _toggleFlashlight,
                ),
              ),
            ),
          ),
        ],
      ),
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
          width: 64,
          height: 64,
          child: Icon(icon, size: 32, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x80FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final len = size.width * 0.25;
    final r = size.width * 0.1;

    Path corner(Offset origin, int dx, int dy) {
      final p = Path();
      p.moveTo(origin.dx, origin.dy + dy * len);
      p.lineTo(origin.dx, origin.dy + dy * r);
      p.quadraticBezierTo(
        origin.dx,
        origin.dy,
        origin.dx + dx * r,
        origin.dy,
      );
      p.lineTo(origin.dx + dx * len, origin.dy);
      return p;
    }

    canvas.drawPath(corner(Offset.zero, 1, 1), paint);
    canvas.drawPath(corner(Offset(size.width, 0), -1, 1), paint);
    canvas.drawPath(corner(Offset(0, size.height), 1, -1), paint);
    canvas.drawPath(corner(Offset(size.width, size.height), -1, -1), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PermissionsModal extends StatefulWidget {
  final MobileScannerController controller;

  const _PermissionsModal({required this.controller});

  @override
  State<_PermissionsModal> createState() => _PermissionsModalState();
}

class _PermissionsModalState extends State<_PermissionsModal> {
  Future<void> _request() async {
    await widget.controller.start();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedModalCard(
      headerIcon: Icons.camera_alt,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: AppText('page.unlock.need-permission'.tr()),
          ),
          AppButton(
            onPressed: _request,
            child: AppText(
              'page.unlock.grant-permission'.tr(),
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            type: AppButtonType.none,
            onPressed: () => context.replace('/unlock/manual'),
            child: AppText(
              'page.unlock.enter-serial'.tr(),
              color: AppColors.highlight,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _close,
            child: AppText(
              'common.cancel'.tr(),
              color: AppColors.highlight,
            ),
          ),
        ],
      ),
    );
  }
}
