import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ThemedModalCard extends StatelessWidget {
  final IconData headerIcon;
  final Widget child;

  const ThemedModalCard({
    super.key,
    required this.headerIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(headerIcon, size: 32, color: AppColors.textDark),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showThemedModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0x00363636),
    builder: builder,
  );
}
