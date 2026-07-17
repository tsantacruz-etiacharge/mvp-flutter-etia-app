import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/menu_button.dart';
import '../../widgets/screen_view.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenView(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IconHeader(),
            Padding(
              padding: AppDimensions.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: AppText(
                      'page.support.title'.tr(),
                      type: AppTextType.subtitleBold,
                    ),
                  ),
                  MenuButton(
                    icon: Icons.question_mark,
                    text: 'page.faq.title'.tr(),
                    onPressed: () => context.push('/more/support/faq'),
                  ),
                  MenuButton(
                    icon: Icons.connect_without_contact,
                    text: 'page.contact.title'.tr(),
                    onPressed: () => context.push('/more/support/contact'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
