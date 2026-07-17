import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app_text_field.dart';

class EmailField extends StatelessWidget {
  final TextEditingController? controller;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const EmailField({
    super.key,
    this.controller,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'form.email'.tr(),
      keyboardType: TextInputType.emailAddress,
      hasError: hasError,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
