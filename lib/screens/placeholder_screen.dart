import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widgets/icon_header.dart';
import '../widgets/screen_view.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ScreenView(
      backButton: true,
      background: const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.background),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconHeader(),
            Text(
              title,
              style: const TextStyle(color: AppColors.textLight, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
