import 'package:flutter/material.dart';

import '../theme/colors.dart';

class IconHeader extends StatelessWidget {
  final bool light;
  final double? size;

  const IconHeader({super.key, this.light = true, this.size});

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 64;
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: light ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.ev_station,
          color: light ? AppColors.textDark : AppColors.textLight,
          size: dimension * 0.55,
        ),
      ),
    );
  }
}
