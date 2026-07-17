import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/screen_view.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_button.dart';

class RestoringSessionScreen extends ConsumerWidget {
  const RestoringSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final offline = auth.authState == AuthState.offline;

    return ScreenView(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconHeader(),
          Center(
            child: offline
                ? const Icon(Icons.wifi_off, size: 80, color: AppColors.textLight)
                : const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppText(
                  offline ? 'error.connection'.tr() : 'common.connecting'.tr(),
                  type: AppTextType.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),
              if (offline) const SizedBox(height: 24),
              if (offline)
                AppButton(
                  width: double.infinity,
                  onPressed: () =>
                      ref.read(authProvider.notifier).restoreSession(),
                  child: AppText(
                    'common.retry'.tr(),
                    type: AppTextType.subtitle,
                    color: AppColors.textDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
