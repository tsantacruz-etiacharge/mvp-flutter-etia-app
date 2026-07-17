import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_text.dart';

class CreditsButton extends StatelessWidget {
  final Color color;
  final int amount;
  final VoidCallback? onPressed;
  final bool disabled;

  const CreditsButton({
    super.key,
    required this.color,
    required this.amount,
    this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: disabled ? 0.7 : 1,
        child: GestureDetector(
          onTap: disabled ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/icons/e-power.png', height: 18, width: 18),
                const SizedBox(height: 12),
                AppText(
                  'page.home.x-amount'.tr(namedArgs: {'amount': '$amount'}),
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
