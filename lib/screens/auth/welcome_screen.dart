import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/screen_view.dart';
import '../../widgets/gradient_curve_view.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  String _flagAsset(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'assets/icons/ar.png';
      case 'pt':
        return 'assets/icons/br.png';
      case 'fr':
        return 'assets/icons/fr.png';
      default:
        return 'assets/icons/us.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return ScreenView(
      topInset: false,
      contentPadding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GradientCurveView(
            colors: AppColors.greenGradient,
            diameterWidthRatio: 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/etia-light.png',
                        height: 48,
                        width: 48,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: () => context.push('/change-language'),
                        child: Image.asset(
                          _flagAsset(languageCode),
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            'page.welcome.title-1'.tr(),
                            type: AppTextType.subtitle,
                            color: AppColors.textDark,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AppText(
                            'page.welcome.title-2'.tr(),
                            type: AppTextType.title,
                            color: AppColors.textDark,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/car-charging.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64).copyWith(top: 64),
            child: Column(
              children: [
                AppButton(
                  type: AppButtonType.primary,
                  sharpCorner: AppButtonCorner.topRight,
                  onPressed: () => context.push('/signup'),
                  child: AppText(
                    'common.sign-up'.tr(),
                    type: AppTextType.subtitle,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  type: AppButtonType.secondary,
                  sharpCorner: AppButtonCorner.bottomLeft,
                  onPressed: () => context.push('/signin'),
                  child: AppText(
                    'common.sign-in'.tr(),
                    type: AppTextType.subtitle,
                    color: AppColors.textLight,
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
