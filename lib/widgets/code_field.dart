import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';

class CodeField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CodeField({
    super.key,
    this.controller,
    this.placeholder,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.error : AppColors.textLight;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 22,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: AppColors.textLight.withValues(alpha: 0.5),
          fontSize: 16,
          letterSpacing: 0,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
