import 'package:flutter/material.dart';

import 'back_button.dart';

class ScreenView extends StatelessWidget {
  final Widget? background;
  final Widget child;
  final bool topInset;
  final bool bottomInset;
  final bool backButton;
  final Color? backButtonColor;
  final EdgeInsets? contentPadding;

  const ScreenView({
    super.key,
    this.background,
    required this.child,
    this.topInset = true,
    this.bottomInset = true,
    this.backButton = false,
    this.backButtonColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (background != null) Positioned.fill(child: background!),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              top: topInset ? insets.top : 0,
              bottom: bottomInset ? insets.bottom : 0,
            ),
            child: Padding(
              padding: contentPadding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
        if (backButton)
          Positioned(
            top: insets.top,
            left: 0,
            child: BackButtonWidget(
              color: backButtonColor,
            ),
          ),
      ],
    );
  }
}
