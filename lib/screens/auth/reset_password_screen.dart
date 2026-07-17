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
import '../../widgets/icon_header.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_button.dart';
import '../../widgets/email_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() => _submitted = true);
    if (!isValidEmail(_emailController.text)) return;

    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).authApi.sendPasswordReset(_emailController.text);
      if (mounted) {
        context.replace(
          '/reset-password/check-code?email=${Uri.encodeComponent(_emailController.text)}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          ref.read(messageProvider.notifier).showError('error.email-not-registered'.tr());
        } else {
          ref.read(messageProvider.notifier).showError('error.unexpected'.tr());
        }
      } else {
        ref.read(messageProvider.notifier).showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AppText(
                        'page.reset-password.title'.tr(),
                        type: AppTextType.subtitleBold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AppText('page.reset-password.text'.tr()),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AppText(
                          'page.reset-password.hint'.tr(),
                          type: AppTextType.hint,
                        ),
                      ),
                      EmailField(
                        controller: _emailController,
                        hasError: _submitted && !isValidEmail(_emailController.text),
                        onSubmitted: (_) => _onSubmit(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: AppButton(
              type: AppButtonType.primary,
              width: double.infinity,
              loading: _loading,
              onPressed: _onSubmit,
              child: AppText(
                'page.reset-password.send'.tr(),
                type: AppTextType.subtitle,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
