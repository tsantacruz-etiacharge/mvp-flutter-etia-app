import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

class BackButtonWidget extends StatelessWidget {
  final Color? color;

  const BackButtonWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final borderColor = color ?? AppColors.highlight;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        child: InkWell(
          onTap: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_left,
              size: 16,
              color: color ?? AppColors.highlight,
            ),
          ),
        ),
      ),
    );
  }
}
