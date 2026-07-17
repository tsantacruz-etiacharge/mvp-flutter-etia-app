import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/expandable_button.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/screen_scroll_view.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

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
            colors: AppColors.blueGradient,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ).copyWith(bottom: AppDimensions.paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IconHeader(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: AppText(
              'page.support.title'.tr(),
              type: AppTextType.subtitleBold,
            ),
          ),
          for (var i = 1; i <= 8; i++)
            ExpandableButton(
              title: 'page.faq.question-$i'.tr(),
              content: 'page.faq.answer-$i'.tr(),
            ),
        ],
      ),
    );
  }
}
