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
import '../../widgets/email_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/validation_check.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  bool get _emailValid => isValidEmail(_emailController.text);
  bool get _passwordValid => isValidPassword(_passwordController.text);
  bool get _repeatValid =>
      isValidRepeatPassword(_repeatController.text, _passwordController.text);

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_emailValid || !_passwordValid || !_repeatValid) return;

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signUp(
            _emailController.text,
            _passwordController.text,
          );
      if (mounted) {
        context.push(
          '/verify-email?email=${Uri.encodeComponent(_emailController.text)}'
          '&password=${Uri.encodeComponent(_passwordController.text)}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          ref.read(messageProvider.notifier).showError('error.email-taken'.tr());
        } else {
          ref.read(messageProvider.notifier).showError('error.unexpected'.tr());
        }
      } else {
        ref.read(messageProvider.notifier).showError('error.connection'.tr());
      }
    } catch (_) {
      ref.read(messageProvider.notifier).showError('error.connection'.tr());
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
            children: [
              const IconHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    'common.sign-up'.tr(),
                    type: AppTextType.title,
                  ),
                ),
              ),
              EmailField(
                controller: _emailController,
                hasError: _submitted && !_emailValid,
              ),
              const SizedBox(height: 32),
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
                onSubmitted: (_) => _submit(),
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
                'common.sign-up'.tr(),
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
