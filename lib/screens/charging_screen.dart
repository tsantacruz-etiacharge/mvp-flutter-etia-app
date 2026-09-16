import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/charging_session.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../providers/session_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../widgets/app_button.dart';
import '../theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/progress_circle.dart';
import '../widgets/screen_view.dart';
import '../widgets/themed_modal.dart';

class ChargingScreen extends ConsumerStatefulWidget {
  const ChargingScreen({super.key});

  @override
  ConsumerState<ChargingScreen> createState() => _ChargingScreenState();
}

class _ChargingScreenState extends ConsumerState<ChargingScreen> {
  Timer? _clockTimer;
  Timer? _pollTimer;
  Duration _remaining = Duration.zero;
  bool _stopping = false;

  /// Last known session, kept across poll failures (prod keeps showing the
  /// previous session and only toasts on refresh errors).
  ChargingSession? _lastSession;

  @override
  void initState() {
    super.initState();
    // 1s repaint for the countdown (no network).
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // 5s session refetch, mirroring SessionContext.tsx polling.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) ref.invalidate(sessionProvider);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Duration _remainingFor(ChargingSession session) {
    final start = DateTime.tryParse(session.timeStart);
    if (start == null) return Duration.zero;
    final end = start.add(Duration(minutes: session.limitMinutes));
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _stop(ChargingSession session) async {
    if (_stopping) return;
    final message = ref.read(messageProvider.notifier);
    setState(() => _stopping = true);
    try {
      await ref.read(apiClientProvider).sessionApi.stop(session);
      ref.invalidate(sessionProvider);
      if (!mounted) return;
      context.go('/main');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        // Already finished remotely: nothing to stop, leave like prod
        // would after its next poll (session null -> home).
        ref.invalidate(sessionProvider);
        if (!mounted) return;
        context.go('/main');
        return;
      }
      message.showError(
        (e.response != null ? 'error.unexpected' : 'error.connection').tr(),
      );
      if (mounted) setState(() => _stopping = false);
    }
  }

  void _confirmStop(ChargingSession session) {
    showThemedModal(
      context: context,
      builder: (dialogContext) => ThemedModalCard(
        headerIcon: Icons.ev_station,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: AppText('page.charging.stop-confirmation'.tr()),
            ),
            AppButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(
                'page.charging.continue'.tr(),
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              type: AppButtonType.none,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _stop(session);
              },
              child: AppText(
                'page.charging.stop'.tr(),
                color: AppColors.highlight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () => _lastSession != null
          ? _buildContent(_lastSession!)
          : const ColoredBox(
              color: AppColors.background,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
      // Poll failures keep the last known session on screen instead of
      // blanking (prod toasts and keeps the old session).
      error: (_, _) => _lastSession != null
          ? _buildContent(_lastSession!)
          : const ColoredBox(color: AppColors.background),
      data: (session) {
        if (session == null) {
          // Finished remotely (or stopped): leave, like Redirect /home.
          _lastSession = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/main');
          });
          return const ColoredBox(color: AppColors.background);
        }
        _lastSession = session;
        return _buildContent(session);
      },
    );
  }

  Widget _buildContent(ChargingSession session) {
    _remaining = _remainingFor(session);
    final progress = session.limitMinutes == 0
        ? 0.0
        : 1 - (_remaining.inSeconds / 60) / session.limitMinutes;

    final start = DateTime.tryParse(session.timeStart);
    final end = start?.add(Duration(minutes: session.limitMinutes));
    final interval = start != null && end != null
        ? '${_formatTime(start)} – ${_formatTime(end)}'
        : '';

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;

    return ScreenView(
      backButton: true,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.blueGradient,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.only(
        top: AppDimensions.paddingTop,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingBottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AppText(
              'page.charging.title'.tr(),
              type: AppTextType.subtitleBold,
            ),
          ),
          Center(
            child: SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: ProgressCircle(progress: progress)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${session.energyKwh.toStringAsFixed(2)}kWh',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 32,
                          height: 36 / 32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppText('page.charging.charged'.tr()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: AppColors.darkGreenGradient,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        'page.charging.remaining-time'.tr(
                          namedArgs: {'time': '${hours}h ${minutes}m'},
                        ),
                        type: AppTextType.defaultBold,
                        color: AppColors.textDark,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: AppText(
                          interval,
                          type: AppTextType.hint,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Image.asset(
                              'assets/icons/e-power.png',
                              height: 32,
                              width: 32,
                            ),
                          ),
                          AppText(
                            '${session.credits}',
                            type: AppTextType.titleBold,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: AppText(
                          'page.charging.credits-used'.tr(),
                          type: AppTextType.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppButton(
              type: AppButtonType.secondary,
              loading: _stopping,
              onPressed: _stopping ? null : () => _confirmStop(session),
              child: AppText(
                'page.charging.stop'.tr(),
                type: AppTextType.subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
