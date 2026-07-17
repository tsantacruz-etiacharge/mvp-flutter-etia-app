import 'package:flutter/material.dart';

import 'colors.dart';

enum AppTextType {
  defaultType,
  defaultBold,
  title,
  titleBold,
  subtitle,
  subtitleBold,
  link,
  hint,
  label,
}

class AppTextStyles {
  static const TextStyle defaultType = TextStyle(
    fontSize: 16,
    height: 20 / 16,
  );

  static const TextStyle defaultBold = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle title = TextStyle(
    fontSize: 30,
    height: 34 / 30,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle titleBold = TextStyle(
    fontSize: 30,
    height: 34 / 30,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle subtitleBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    decoration: TextDecoration.underline,
    color: AppColors.surface,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    height: 16 / 14,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.highlight,
  );

  static TextStyle of(AppTextType type) {
    switch (type) {
      case AppTextType.defaultType:
        return defaultType;
      case AppTextType.defaultBold:
        return defaultBold;
      case AppTextType.title:
        return title;
      case AppTextType.titleBold:
        return titleBold;
      case AppTextType.subtitle:
        return subtitle;
      case AppTextType.subtitleBold:
        return subtitleBold;
      case AppTextType.link:
        return link;
      case AppTextType.hint:
        return hint;
      case AppTextType.label:
        return label;
    }
  }
}
