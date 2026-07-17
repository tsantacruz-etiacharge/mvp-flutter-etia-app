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
import '../../widgets/app_text_field.dart';
import '../../widgets/screen_scroll_view.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _codeController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _codeValid => _codeController.text.trim().length == 10;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_codeValid) return;

    setState(() => _loading = true);
    final auth = ref.read(authProvider);
    final message = ref.read(messageProvider.notifier);
    try {
      await ref
          .read(apiClientProvider)
          .userApi
          .addCompany(auth.user!.self, _codeController.text.trim());
      if (mounted) context.pushReplacement('/more/private');
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          message.showError('error.invalid-code'.tr());
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
      bottomInset: false,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.greenGradient,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ).copyWith(top: AppDimensions.paddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AppText(
              'page.private.title'.tr(),
              type: AppTextType.subtitleBold,
            ),
          ),
          AppText('page.private.text'.tr()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Image.asset(
              'assets/images/charging-station.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _codeController,
                    label: 'form.code'.tr(),
                    hasError: _submitted && !_codeValid,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) {
                      if (_submitted) setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: AppButton(
                    type: AppButtonType.secondary,
                    loading: _loading,
                    onPressed: _submit,
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textLight,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
