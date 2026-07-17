import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/icon_header.dart';
import '../widgets/menu_button.dart';
import '../widgets/screen_view.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _share() async {
    await Share.share('page.settings.recommend-share'.tr());
  }

  void _onLogoutPress(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        title: AppText('common.sign-out'.tr(), type: AppTextType.subtitleBold),
        content: AppText('common.sign-out.confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: AppText('common.cancel'.tr(), color: AppColors.highlight),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authProvider.notifier).signOut();
            },
            child: AppText('common.sign-out'.tr(), color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenView(
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
                      'page.settings.title'.tr(),
                      type: AppTextType.subtitleBold,
                    ),
                  ),
                  MenuButton(
                    icon: Icons.person_outline,
                    text: 'page.account.title'.tr(),
                    onPressed: () => context.push('/more/account'),
                  ),
                  MenuButton(
                    icon: Icons.ev_station,
                    text: 'page.private.title'.tr(),
                    onPressed: () => context.push('/more/private'),
                  ),
                  MenuButton(
                    icon: Icons.language,
                    text: 'page.language.title'.tr(),
                    onPressed: () => context.push('/change-language'),
                  ),
                  MenuButton(
                    icon: Icons.support_agent,
                    text: 'page.support.title'.tr(),
                    onPressed: () => context.push('/more/support'),
                  ),
                  MenuButton(
                    icon: Icons.info_outline,
                    text: 'page.about.title'.tr(),
                    onPressed: () => context.push('/more/about'),
                  ),
                  MenuButton(
                    icon: Icons.share,
                    text: 'page.settings.recommend'.tr(),
                    onPressed: _share,
                  ),
                  MenuButton(
                    icon: Icons.logout,
                    text: 'common.sign-out'.tr(),
                    onPressed: () => _onLogoutPress(context, ref),
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
