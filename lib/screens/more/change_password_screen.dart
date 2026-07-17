import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/password_field.dart';
import '../../widgets/screen_scroll_view.dart';
import '../../widgets/validation_check.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _oldController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  bool get _lengthValid =>
      _passwordController.text.length >= 8 && _passwordController.text.length <= 64;
  bool get _numberValid => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _letterValid =>
      RegExp(r'[a-z]').hasMatch(_passwordController.text) &&
      RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _passwordValid => _lengthValid && _numberValid && _letterValid;
  bool get _repeatValid =>
      _repeatController.text == _passwordController.text &&
      _repeatController.text.isNotEmpty;
  bool get _oldValid =>
      _oldController.text.length >= 8 && _oldController.text.length <= 64;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_oldValid || !_passwordValid || !_repeatValid) return;

    setState(() => _loading = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      await ref.read(apiClientProvider).authApi.changePassword(
            auth.user!.email,
            _passwordController.text,
            _oldController.text,
          );
      message.showSuccess('page.change-password.changed'.tr());
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/more/account');
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 403) {
          message.showError('error.invalid-password'.tr());
        } else {
          message.showError('error.unexpected'.tr());
        }
      } else {
        message.showError('error.connection'.tr());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      backButton: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ).copyWith(bottom: AppDimensions.paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppText(
                  'page.change-password.title'.tr(),
                  type: AppTextType.subtitleBold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppText('page.change-password.new'.tr()),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordField(
                controller: _oldController,
                label: 'form.current-password'.tr(),
                hasError: _submitted && !_oldValid,
                onChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
              const SizedBox(height: 32),
              PasswordField(
                controller: _passwordController,
                label: 'form.new-password'.tr(),
                hasError: _submitted && !_passwordValid,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              ValidationCheck(
                value: _passwordController.text,
                isValid: _lengthValid,
                text: 'form.password.length'.tr(),
              ),
              ValidationCheck(
                value: _passwordController.text,
                isValid: _numberValid,
                text: 'form.password.number'.tr(),
              ),
              ValidationCheck(
                value: _passwordController.text,
                isValid: _letterValid,
                text: 'form.password.letters'.tr(),
              ),
              const SizedBox(height: 24),
              PasswordField(
                controller: _repeatController,
                label: 'form.repeat-new-password'.tr(),
                hasError: _submitted && !_repeatValid,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_submitted) setState(() {});
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 24),
            child: AppButton(
              type: AppButtonType.primary,
              sharpCorner: AppButtonCorner.bottomLeft,
              loading: _loading,
              onPressed: _submit,
              child: AppText(
                'page.change-password.title'.tr(),
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
