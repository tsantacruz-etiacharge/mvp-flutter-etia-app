import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/screen_scroll_view.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  final _controller = TextEditingController();
  int? _credits;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setCredits(int value) {
    _controller.text = value.toString();
    setState(() => _credits = value);
  }

  void _onChanged(String text) {
    final filtered = text.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = filtered.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.length > 4) {
      _controller.text = _credits?.toString() ?? '';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      return;
    }
    setState(() => _credits = trimmed.isEmpty ? null : int.parse(trimmed));
  }

  void _onSubmit() {
    if (_credits == null) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      backButton: true,
      background: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.aquaGradient,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.only(
        top: AppDimensions.paddingTop,
        left: AppDimensions.paddingHorizontal,
        right: AppDimensions.paddingHorizontal,
        bottom: AppDimensions.paddingBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AppText(
                  'page.credits.title'.tr(),
                  type: AppTextType.subtitleBold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Image.asset(
                      'assets/icons/e-power.png',
                      height: 64,
                      width: 64,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: IntrinsicWidth(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onChanged,
                      textAlign: TextAlign.center,
                      cursorColor: AppColors.textLight,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 64,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.textLight.withValues(alpha: 0.44),
                          fontSize: 64,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickOption(value: 25, borderColor: const Color(0xFF5A999E), onSelect: _setCredits),
              _QuickOption(value: 50, borderColor: const Color(0xFF36A377), onSelect: _setCredits),
              _QuickOption(value: 75, borderColor: const Color(0xFFB1CE36), onSelect: _setCredits),
            ],
          ),
          AppButton(
            sharpCorner: AppButtonCorner.bottomLeft,
            onPressed: _credits == null ? null : _onSubmit,
            disabled: _credits == null,
            child: AppText(
              'common.continue'.tr(),
              type: AppTextType.subtitle,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            type: AppButtonType.secondary,
            onPressed: _credits == null
                ? null
                : () => context.push('/payment/card?credits=$_credits'),
            disabled: _credits == null,
            child: AppText(
              'page.payment.card.pay'.tr(),
              type: AppTextType.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickOption extends StatelessWidget {
  final int value;
  final Color borderColor;
  final ValueChanged<int> onSelect;

  const _QuickOption({
    required this.value,
    required this.borderColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Image.asset(
                  'assets/icons/e-power.png',
                  height: 16,
                  width: 16,
                ),
              ),
              AppText('$value'),
            ],
          ),
        ),
      ),
    );
  }
}
