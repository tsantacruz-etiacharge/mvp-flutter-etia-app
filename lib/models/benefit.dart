import 'package:flutter/material.dart';

Color _parseColor(String? value, Color fallback) {
  if (value == null) return fallback;
  var hex = value.replaceAll('#', '').trim();
  if (hex.length == 6) hex = 'FF$hex';
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

class BenefitCardPalette {
  final Color ui;
  final Color text;

  const BenefitCardPalette({required this.ui, required this.text});

  factory BenefitCardPalette.fromJson(Map<String, dynamic>? json) {
    return BenefitCardPalette(
      ui: _parseColor(json?['ui'] as String?, const Color(0xFF064789)),
      text: _parseColor(json?['text'] as String?, const Color(0xFFFFFFFF)),
    );
  }
}

class BenefitBannerPalette {
  final Color background;
  final Color text;

  const BenefitBannerPalette({required this.background, required this.text});

  factory BenefitBannerPalette.fromJson(Map<String, dynamic>? json) {
    return BenefitBannerPalette(
      background:
          _parseColor(json?['background'] as String?, const Color(0xFF064789)),
      text: _parseColor(json?['text'] as String?, const Color(0xFFFFFFFF)),
    );
  }
}

class BenefitColorPalette {
  final BenefitCardPalette card;
  final Color detailUi;
  final BenefitBannerPalette banner;

  const BenefitColorPalette({
    required this.card,
    required this.detailUi,
    required this.banner,
  });

  factory BenefitColorPalette.fromJson(Map<String, dynamic>? json) {
    return BenefitColorPalette(
      card: BenefitCardPalette.fromJson(json?['card'] as Map<String, dynamic>?),
      detailUi: _parseColor(
        (json?['detail'] as Map<String, dynamic>?)?['ui'] as String?,
        const Color(0xFFFFFFFF),
      ),
      banner:
          BenefitBannerPalette.fromJson(json?['banner'] as Map<String, dynamic>?),
    );
  }
}

class Benefit {
  final String self;
  final String name;
  final String title;
  final String description;
  final BenefitColorPalette colorPalette;
  final String? cardImageUrl;
  final String? detailImageUrl;
  final String? bannerIconUrl;
  final String? termsUrl;
  final bool? active;

  const Benefit({
    required this.self,
    required this.name,
    required this.title,
    required this.description,
    required this.colorPalette,
    this.cardImageUrl,
    this.detailImageUrl,
    this.bannerIconUrl,
    this.termsUrl,
    this.active,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      self: json['self'] as String,
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      colorPalette: BenefitColorPalette.fromJson(
        json['colorPalette'] as Map<String, dynamic>?,
      ),
      cardImageUrl: json['cardImageUrl'] as String?,
      detailImageUrl: json['detailImageUrl'] as String?,
      bannerIconUrl: json['bannerIconUrl'] as String?,
      termsUrl: json['termsUrl'] as String?,
      active: json['active'] as bool?,
    );
  }
}
