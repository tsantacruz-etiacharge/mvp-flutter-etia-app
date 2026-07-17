import 'package:flutter/material.dart';

import '../theme/colors.dart';

class PickerItem<T> {
  final T value;
  final String label;

  const PickerItem({required this.value, required this.label});
}

class Picker<T> extends StatelessWidget {
  final List<PickerItem<T>> items;
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool comfortable;

  const Picker({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.comfortable = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.value == selected;
        return Material(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onSelected(item.value),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: comfortable ? 64 : 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.highlight,
                    width: index < items.length - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: comfortable ? 20 : 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
