import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../widgets/app_button.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/icon_header.dart';
import '../../widgets/screen_scroll_view.dart';

class ManualUnlockScreen extends StatefulWidget {
  const ManualUnlockScreen({super.key});

  @override
  State<ManualUnlockScreen> createState() => _ManualUnlockScreenState();
}

class _ManualUnlockScreenState extends State<ManualUnlockScreen> {
  final _controller = TextEditingController();
  bool _touched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.trim().length >= 4;

  void _submit() {
    setState(() => _touched = true);
    if (!_valid) return;

    final parts = _controller.text.trim().split(';');
    final serial = parts[0];
    final connectorID = parts.length > 1 ? parts[1] : '1';

    context.replace(
      '/unlock/charger?serial=${Uri.encodeComponent(serial)}&connectorID=${Uri.encodeComponent(connectorID)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      backButton: true,
      background: const ColoredBox(color: AppColors.background),
      contentPadding: const EdgeInsets.only(
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const IconHeader(),
              AppText(
                'page.unlock.enter-serial'.tr(),
                type: AppTextType.subtitleBold,
              ),
            ],
          ),
          AppTextField(
            controller: _controller,
            label: 'page.unlock.serial'.tr(),
            keyboardType: TextInputType.text,
            hasError: _touched && !_valid,
            onChanged: (_) {
              if (_touched) setState(() {});
            },
            onSubmitted: (_) => _submit(),
          ),
          AppButton(
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
