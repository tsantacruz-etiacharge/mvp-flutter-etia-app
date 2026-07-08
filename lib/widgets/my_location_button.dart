import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MyLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MyLocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 50,
      child: Material(
        elevation: 6,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
