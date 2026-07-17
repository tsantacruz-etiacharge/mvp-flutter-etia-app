import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/screen_scroll_view.dart';

const _supportEmail = 'ventas@etiacharge.com';
const _supportPhone = '+54 9 11 5798-3831';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _subjectValid => _subjectController.text.trim().isNotEmpty;
  bool get _bodyValid => _bodyController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_subjectValid || !_bodyValid) return;

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent(_subjectController.text)}'
          '&body=${Uri.encodeComponent(_bodyController.text)}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _contactInfo(String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(value, type: AppTextType.defaultBold, color: AppColors.textDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      backButton: true,
      bottomInset: false,
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
              AppText('page.contact.title'.tr(), type: AppTextType.subtitleBold),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _contactInfo(_supportEmail),
                _contactInfo(_supportPhone),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AppTextField(
                    controller: _subjectController,
                    label: 'page.contact.subject'.tr(),
                    textInputAction: TextInputAction.next,
                    hasError: _submitted && !_subjectValid,
                    onChanged: (_) {
                      if (_submitted) setState(() {});
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AppTextField(
                    controller: _bodyController,
                    label: 'page.contact.description'.tr(),
                    maxLines: null,
                    minLines: 4,
                    hasError: _submitted && !_bodyValid,
                    onChanged: (_) {
                      if (_submitted) setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            type: AppButtonType.primary,
            onPressed: _submit,
            child: AppText(
              'common.continue'.tr(),
              type: AppTextType.subtitle,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
