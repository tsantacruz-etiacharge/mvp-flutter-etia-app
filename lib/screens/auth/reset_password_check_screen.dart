import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/screen_scroll_view.dart';
import '../../widgets/gradient_curve_view.dart';
import '../../widgets/code_field.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_button.dart';

class ResetPasswordCheckScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordCheckScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordCheckScreen> createState() =>
      _ResetPasswordCheckScreenState();
}

class _ResetPasswordCheckScreenState
    extends ConsumerState<ResetPasswordCheckScreen> {
  final _codeController = TextEditingController();
  bool _submitted = false;
  bool _resending = false;

  Timer? _timer;
  DateTime _timeSent = DateTime.now();
  Duration _remaining = const Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final target = _timeSent.add(const Duration(minutes: 2));
      final diff = target.difference(DateTime.now());
      if (mounted) setState(() => _remaining = diff);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  String _formatRemaining() {
    final total = _remaining.inSeconds;
    final m = (total ~/ 60).clamp(0, 99).toString().padLeft(2, '0');
    final s = (total % 60).clamp(0, 59).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _onResend() async {
    setState(() => _resending = true);
    try {
      await ref.read(apiClientProvider).authApi.sendPasswordReset(widget.email);
      setState(() {
        _timeSent = DateTime.now();
        _remaining = const Duration(minutes: 2);
      });
    } on DioException catch (e) {
      if (e.response != null) {
        ref.read(messageProvider.notifier).showError('error.sending-email'.tr());
      } else {
        ref.read(messageProvider.notifier).showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _onSubmit() async {
    setState(() => _submitted = true);
    if (!isValidCode(_codeController.text)) return;

    try {
      await ref.read(apiClientProvider).authApi.checkPasswordReset(
            widget.email,
            _codeController.text,
          );
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          ref.read(messageProvider.notifier).showError('error.invalid-code'.tr());
        } else {
          ref.read(messageProvider.notifier).showError('error.unexpected'.tr());
        }
      } else {
        ref.read(messageProvider.notifier).showError('error.connection'.tr());
      }
      return;
    }

    if (mounted) {
      context.replace(
        '/reset-password/new-password?email=${Uri.encodeComponent(widget.email)}'
        '&code=${Uri.encodeComponent(_codeController.text)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _remaining <= Duration.zero;

    return ScreenScrollView(
      backButton: true,
      contentPadding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GradientCurveView(
            colors: AppColors.cyanGradient,
            diameterWidthRatio: 2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 48).copyWith(bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48, bottom: 32),
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Image.asset(
                      'assets/images/reset-password.png',
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CodeField(
                        controller: _codeController,
                        placeholder: 'form.code'.tr(),
                        hasError: _submitted && !isValidCode(_codeController.text),
                        onSubmitted: (_) => _onSubmit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: AppButton(
                        type: AppButtonType.secondary,
                        onPressed: _onSubmit,
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: AppButton(
              type: AppButtonType.secondary,
              width: double.infinity,
              loading: _resending,
              disabled: !canResend,
              onPressed: canResend ? _onResend : null,
              child: AppText(
                canResend ? 'form.code.resend'.tr() : _formatRemaining(),
                type: AppTextType.subtitle,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
