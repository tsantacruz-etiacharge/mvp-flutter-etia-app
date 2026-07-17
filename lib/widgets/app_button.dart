import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum AppButtonType { primary, secondary, none }

enum AppButtonCorner { none, topRight, bottomLeft }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonType type;
  final AppButtonCorner sharpCorner;
  final bool loading;
  final bool disabled;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = AppButtonType.primary,
    this.sharpCorner = AppButtonCorner.none,
    this.loading = false,
    this.disabled = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading || onPressed == null;

    final Color? backgroundColor;
    final Color? borderColor;
    switch (type) {
      case AppButtonType.primary:
        backgroundColor = AppColors.primary;
        borderColor = null;
      case AppButtonType.secondary:
        backgroundColor = Colors.transparent;
        borderColor = AppColors.highlight;
      case AppButtonType.none:
        backgroundColor = Colors.transparent;
        borderColor = null;
    }

    final textColor =
        type == AppButtonType.primary ? AppColors.textDark : AppColors.textLight;

    BorderRadius radius = BorderRadius.circular(16);
    if (sharpCorner == AppButtonCorner.topRight) {
      radius = BorderRadius.only(
        topLeft: const Radius.circular(16),
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      );
    } else if (sharpCorner == AppButtonCorner.bottomLeft) {
      radius = BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: Opacity(
        opacity: isDisabled ? 0.45 : 1,
        child: Material(
          color: backgroundColor,
          borderRadius: radius,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: radius,
            splashFactory: InkRipple.splashFactory,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: borderColor != null
                    ? Border.all(color: borderColor, width: 1)
                    : null,
              ),
              alignment: Alignment.center,
              child: loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: textColor,
                        strokeWidth: 3,
                      ),
                    )
                  : DefaultTextStyle(
                      style: TextStyle(color: textColor),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
