import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'app_text.dart';

class TimeField extends StatefulWidget {
  final List<int> hours;
  final List<int> minutes;
  final int initialHours;
  final int initialMinutes;
  final void Function(int hours, int minutes) onChanged;

  const TimeField({
    super.key,
    required this.hours,
    required this.minutes,
    required this.onChanged,
    this.initialHours = 1,
    this.initialMinutes = 0,
  });

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  late final List<int> _hoursData;
  late final List<int> _minutesData;
  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;

  int _hours = 0;
  int _minutes = 0;

  static const double _itemHeight = 64;

  @override
  void initState() {
    super.initState();
    _hoursData = widget.hours.reversed.toList();
    _minutesData = widget.minutes.reversed.toList();
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _hoursController =
        FixedExtentScrollController(initialItem: _hoursData.indexOf(_hours));
    _minutesController = FixedExtentScrollController(
        initialItem: _minutesData.indexOf(_minutes));
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _apply(int hours, int minutes) {
    setState(() {
      _hours = hours;
      _minutes = minutes;
    });
    widget.onChanged(hours, minutes);
    final hIndex = _hoursData.indexOf(hours);
    final mIndex = _minutesData.indexOf(minutes);
    if (_hoursController.selectedItem != hIndex) {
      _hoursController.animateToItem(hIndex,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
    if (_minutesController.selectedItem != mIndex) {
      _minutesController.animateToItem(mIndex,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  void _setHours(int value) {
    if (value == 0 && _minutes == 0) {
      _apply(0, 15);
    } else if (value == 24) {
      _apply(24, 0);
    } else {
      _apply(value, _minutes);
    }
  }

  void _setMinutes(int value) {
    if (value == 0 && _hours == 0) {
      _apply(1, value);
    } else if (_hours == 24) {
      _apply(23, value);
    } else {
      _apply(_hours, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _wheel(_hoursData, _hoursController, _setHours),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: AppText(':', type: AppTextType.title),
        ),
        _wheel(_minutesData, _minutesController, _setMinutes),
      ],
    );
  }

  Widget _wheel(
    List<int> data,
    FixedExtentScrollController controller,
    ValueChanged<int> onSelected,
  ) {
    return SizedBox(
      width: 72,
      height: _itemHeight * 3,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: _itemHeight,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => onSelected(data[index]),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: data.length,
          builder: (context, index) {
            return Center(
              child: Text(
                data[index].toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
