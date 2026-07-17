import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/screen_scroll_view.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _values = <_AboutValue>[
    _AboutValue('innovation', 'page.about.innovation-title', 'page.about.innovation-text'),
    _AboutValue('commitment', 'page.about.commitment-title', 'page.about.commitment-text'),
    _AboutValue('sustainability', 'page.about.sustainability-title', 'page.about.sustainability-text'),
    _AboutValue('adaptability', 'page.about.adaptability-title', 'page.about.adaptability-text'),
    _AboutValue('development', 'page.about.development-title', 'page.about.development-text'),
  ];

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://www.etiacharge.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ScreenScrollView(
      bottomInset: false,
      backButton: true,
      backButtonColor: AppColors.textDark,
      background: const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/about.png',
                width: width,
                height: width * (1920 / 1080),
                fit: BoxFit.contain,
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.surface],
                      stops: [0.4, 0.8],
                    ),
                  ),
                ),
              ),
              const IconHeader(light: false),
            ],
          ),
          Transform.translate(
            offset: Offset(0, width * -0.45),
            child: Padding(
              padding: AppDimensions.horizontal,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AppText(
                            'page.about.title'.tr(),
                            type: AppTextType.titleBold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AppText(
                            'page.about.text-1'.tr(),
                            type: AppTextType.subtitle,
                            color: AppColors.textDark,
                          ),
                        ),
                        AppText(
                          'page.about.text-2'.tr(),
                          type: AppTextType.subtitle,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                  for (final v in _values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Image.asset(
                              'assets/icons/${v.icon}.png',
                              width: 80,
                              height: 80,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AppText(
                              v.title.tr(),
                              type: AppTextType.subtitleBold,
                              color: AppColors.textDark,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          AppText(
                            v.text.tr(),
                            type: AppTextType.subtitle,
                            color: AppColors.textDark,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, width * -0.45),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  AppText(
                    'page.about.web'.tr(),
                    type: AppTextType.subtitleBold,
                    color: AppColors.textDark,
                    textAlign: TextAlign.center,
                  ),
                  GestureDetector(
                    onTap: _openWebsite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: AppText(
                        'www.etiacharge.com',
                        type: AppTextType.subtitleBold,
                        color: AppColors.surface,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  AppText(
                    'page.about.more'.tr(),
                    type: AppTextType.subtitleBold,
                    color: AppColors.textDark,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutValue {
  final String icon;
  final String title;
  final String text;

  const _AboutValue(this.icon, this.title, this.text);
}
