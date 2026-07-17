import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_text.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.card, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: AppColors.textLight),
              const SizedBox(width: 16),
              Expanded(child: AppText(text)),
            ],
          ),
        ),
      ),
    );
  }
}
