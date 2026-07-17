import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_text.dart';

class ExpandableButton extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableButton({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableButton> createState() => _ExpandableButtonState();
}

class _ExpandableButtonState extends State<ExpandableButton> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.card, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AppText(widget.title),
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textLight,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Opacity(
              opacity: 0.7,
              child: AppText(widget.content),
            ),
          ),
      ],
    );
  }
}
