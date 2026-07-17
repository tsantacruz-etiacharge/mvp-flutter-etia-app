import 'benefit.dart';

class CalculatedCost {
  final double baseHourlyRate;
  final double hourlyRate;
  final Benefit? benefit;

  const CalculatedCost({
    required this.baseHourlyRate,
    required this.hourlyRate,
    this.benefit,
  });

  factory CalculatedCost.fromJson(Map<String, dynamic> json) {
    return CalculatedCost(
      baseHourlyRate: (json['baseHourlyRate'] as num?)?.toDouble() ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      benefit: json['benefit'] != null
          ? Benefit.fromJson(json['benefit'] as Map<String, dynamic>)
          : null,
    );
  }
}
