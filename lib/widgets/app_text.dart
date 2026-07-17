import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AppText extends StatelessWidget {
  final String data;
  final AppTextType type;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const AppText(
    this.data, {
    super.key,
    this.type = AppTextType.defaultType,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.of(type);
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: base.copyWith(
        color: color ?? AppColors.textLight,
        decoration: type == AppTextType.link ? TextDecoration.underline : null,
      ).merge(style),
    );
  }
}
