import '../models/week_time.dart';

bool isInOpeningHours(DateTime time, OpeningPeriod period) {
  final now = ((time.weekday - 1) * 24 + time.hour) * 60 + time.minute;
  final start = period.open.weekMinutes;
  final end = period.close.weekMinutes;

  if (start <= end) {
    return now >= start && now < end;
  }
  return now >= start || now < end;
}

WeekTime? getNextOpeningTime(DateTime now, List<OpeningPeriod> openingHours) {
  if (openingHours.isEmpty) return null;

  final nowMinutes = ((now.weekday - 1) * 24 + now.hour) * 60 + now.minute;

  WeekTime? nextOpen;
  var minDiff = 1 << 30;

  for (final period in openingHours) {
    final start = period.open.weekMinutes;
    var diff = start - nowMinutes;
    if (diff <= 0) diff += 7 * 24 * 60;
    if (diff < minDiff) {
      minDiff = diff;
      nextOpen = period.open;
    }
  }

  return nextOpen;
}

String formatWeekTime(WeekTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
