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

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _emailValid => isValidEmail(_emailController.text);
  bool get _passwordValid =>
      _passwordController.text.length >= 8 && _passwordController.text.length <= 64;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_emailValid || !_passwordValid) return;

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );
    } on DioException catch (e) {
      if (e.response != null) {
        final status = e.response!.statusCode;
        if (status == 401) {
          ref.read(messageProvider.notifier).showError('error.invalid-auth'.tr());
        } else if (status == 403) {
          if (mounted) {
            context.push(
              '/verify-email?email=${Uri.encodeComponent(_emailController.text)}'
              '&password=${Uri.encodeComponent(_passwordController.text)}',
            );
          }
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
          const IconHeader(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    'common.sign-in'.tr(),
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
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.push('/reset-password'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: AppText(
                      'page.sign-in.forgot-password'.tr(),
                      type: AppTextType.link,
                    ),
                  ),
                ),
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
                'common.sign-in'.tr(),
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
