class WeekTime {
  final int weekday;
  final int hour;
  final int minute;

  const WeekTime({
    required this.weekday,
    required this.hour,
    required this.minute,
  });

  factory WeekTime.fromJson(Map<String, dynamic> json) {
    return WeekTime(
      weekday: (json['weekday'] as num?)?.toInt() ?? 0,
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
    );
  }

  int get weekMinutes => (weekday * 24 + hour) * 60 + minute;
}

class OpeningPeriod {
  final WeekTime open;
  final WeekTime close;

  const OpeningPeriod({required this.open, required this.close});

  factory OpeningPeriod.fromJson(Map<String, dynamic> json) {
    return OpeningPeriod(
      open: WeekTime.fromJson(json['open'] as Map<String, dynamic>),
      close: WeekTime.fromJson(json['close'] as Map<String, dynamic>),
    );
  }
}
