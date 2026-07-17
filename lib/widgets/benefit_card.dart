import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/benefit.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'app_text.dart';

class BenefitCard extends StatelessWidget {
  final Benefit benefit;
  final double width;
  final VoidCallback? onPressed;

  const BenefitCard({
    super.key,
    required this.benefit,
    required this.width,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: width / 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.card),
              if (benefit.cardImageUrl != null)
                CachedNetworkImage(
                  imageUrl: benefit.cardImageUrl!,
                  fit: BoxFit.cover,
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x4D064789)],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: AppText(
                    (benefit.active ?? false)
                        ? 'page.benefits.active'.tr()
                        : 'page.benefits.activate'.tr(),
                    type: AppTextType.hint,
                    color: AppColors.textLight,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
