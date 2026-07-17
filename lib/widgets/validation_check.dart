import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ValidationCheck extends StatelessWidget {
  final String value;
  final bool isValid;
  final String text;

  const ValidationCheck({
    super.key,
    required this.value,
    required this.isValid,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final touched = value.isNotEmpty;
    final color = (!touched || isValid) ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Icon(
          touched ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
