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
import '../../widgets/icon_header.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_button.dart';
import '../../widgets/password_field.dart';
import '../../widgets/validation_check.dart';

class ResetPasswordNewScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordNewScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ResetPasswordNewScreen> createState() =>
      _ResetPasswordNewScreenState();
}

class _ResetPasswordNewScreenState extends ConsumerState<ResetPasswordNewScreen> {
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  bool get _passwordValid => isValidPassword(_passwordController.text);
  bool get _repeatValid =>
      isValidRepeatPassword(_repeatController.text, _passwordController.text);

  Future<void> _onSubmit() async {
    setState(() => _submitted = true);
    if (!_passwordValid || !_repeatValid) return;

    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).authApi.confirmPasswordReset(
            widget.email,
            widget.code,
            _passwordController.text,
          );
      if (mounted) context.go('/signin');
    } on DioException catch (e) {
      if (e.response != null) {
        ref.read(messageProvider.notifier).showError('error.unexpected'.tr());
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
      contentPadding: EdgeInsets.symmetric(horizontal: 24).copyWith(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
                child: AppText('page.reset-password.new'.tr()),
              ),
            ],
          ),
          Column(
            children: [
              PasswordField(
                controller: _passwordController,
                hasError: _submitted && !_passwordValid,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              ValidationCheck(
                value: _passwordController.text,
                isValid: passwordHasLength(_passwordController.text),
                text: 'form.password.length'.tr(),
              ),
              ValidationCheck(
                value: _passwordController.text,
                isValid: passwordHasNumber(_passwordController.text),
                text: 'form.password.number'.tr(),
              ),
              ValidationCheck(
                value: _passwordController.text,
                isValid: passwordHasLetters(_passwordController.text),
                text: 'form.password.letters'.tr(),
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _repeatController,
                label: 'form.repeat-password'.tr(),
                hasError: _submitted && !_repeatValid,
                onSubmitted: (_) => _onSubmit(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppButton(
              type: AppButtonType.primary,
              width: double.infinity,
              loading: _loading,
              onPressed: _onSubmit,
              child: AppText(
                'page.reset-password.title'.tr(),
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
