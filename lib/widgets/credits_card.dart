import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'app_text.dart';

class CreditsCard extends StatelessWidget {
  final int credits;

  const CreditsCard({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.decimalPattern().format(credits);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -12,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/icons/e-power.png',
                  height: 180,
                  width: 180,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Image.asset(
                    'assets/icons/e-power.png',
                    height: 40,
                    width: 40,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(formatted, type: AppTextType.title),
                    AppText('page.home.credits'.tr(), type: AppTextType.hint),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
