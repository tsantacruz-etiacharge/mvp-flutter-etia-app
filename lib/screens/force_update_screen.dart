import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../utils/app_logger.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/icon_header.dart';
import '../widgets/screen_view.dart';

/// Mirrors force-update.tsx in etia-user-app.
/// Reached via router guard when the backend marks this version unsupported.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<void> _goToStore() async {
    final url = Platform.isIOS ? Env.appStoreUrl : Env.playStoreUrl;
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      AppLogger.warning('Could not open store URL', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenView(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ).copyWith(bottom: AppDimensions.paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconHeader(),
          const Icon(
            Icons.system_update,
            size: 80,
            color: AppColors.textLight,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppText(
                  'page.force-update.title'.tr(),
                  type: AppTextType.titleBold,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.card,
                ),
                child: AppText(
                  'page.force-update.message'.tr(),
                  type: AppTextType.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppButton(
                  onPressed: _goToStore,
                  child: AppText(
                    'common.update'.tr(),
                    type: AppTextType.subtitle,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
