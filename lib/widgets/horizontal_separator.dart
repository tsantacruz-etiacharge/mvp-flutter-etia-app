import 'package:flutter/material.dart';

import '../theme/colors.dart';

class HorizontalSeparator extends StatelessWidget {
  const HorizontalSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.separator, width: 1),
          ),
        ),
        child: SizedBox(height: 0),
      ),
    );
  }
}
