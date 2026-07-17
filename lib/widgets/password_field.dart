import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../theme/colors.dart';
import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const PasswordField({
    super.key,
    this.controller,
    this.label,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label ?? 'form.password'.tr(),
      obscureText: _hidden,
      hasError: widget.hasError,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _hidden = !_hidden),
          child: Icon(
            _hidden ? Icons.visibility_off : Icons.visibility,
            color: AppColors.highlight,
            size: 24,
          ),
        ),
      ),
    );
  }
}
