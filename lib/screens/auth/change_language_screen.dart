import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/screen_view.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/app_text.dart';
import '../../widgets/picker.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  static const _items = [
    PickerItem(value: 'en', label: '🇺🇸  English'),
    PickerItem(value: 'es', label: '🇦🇷  Español'),
    PickerItem(value: 'fr', label: '🇫🇷  Français'),
    PickerItem(value: 'pt', label: '🇧🇷  Português'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenView(
      backButton: true,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.greenGradient,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Image.asset(
                'assets/images/languages.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 32),
                  child: AppText(
                    'page.language.title'.tr(),
                    type: AppTextType.title,
                  ),
                ),
                Picker<String>(
                  comfortable: true,
                  items: _items,
                  selected: context.locale.languageCode,
                  onSelected: (value) => context.setLocale(Locale(value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
