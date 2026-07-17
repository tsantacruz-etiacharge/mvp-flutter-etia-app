import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _showLabel = _controller.text.isNotEmpty;
  }

  void _onFocusChange() {
    if (mounted) setState(() => _showLabel = _focusNode.hasFocus || _controller.text.isNotEmpty);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError ? AppColors.error : AppColors.highlight;
    final label = widget.label;

    return Stack(
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          onChanged: (value) {
            if (_showLabel != (value.isNotEmpty || _focusNode.hasFocus)) {
              setState(() => _showLabel = value.isNotEmpty || _focusNode.hasFocus);
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(color: AppColors.highlight, fontSize: 16),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            hintText: _showLabel ? null : label,
            hintStyle: TextStyle(color: AppColors.highlight.withValues(alpha: 0.7), fontSize: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            suffixIcon: widget.suffix,
          ),
        ),
        if (_showLabel && label != null)
          Positioned(
            left: 13,
            top: -11,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.highlight,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String get text => _controller.text;
  TextEditingController get effectiveController => _controller;
}
