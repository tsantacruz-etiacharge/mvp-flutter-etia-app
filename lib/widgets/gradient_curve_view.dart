import 'package:flutter/material.dart';

class GradientCurveView extends StatelessWidget {
  final List<Color> colors;
  final double diameterWidthRatio;
  final EdgeInsetsGeometry? contentPadding;
  final Widget child;

  const GradientCurveView({
    super.key,
    required this.colors,
    required this.diameterWidthRatio,
    this.contentPadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final diameter = width * (diameterWidthRatio < 1 ? 1 : diameterWidthRatio);
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: diameter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(diameter / 2),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: topInset).add(contentPadding ?? EdgeInsets.zero),
          child: child,
        ),
      ],
    );
  }
}
