// Mirrors api/country/response/country.dto.ts in etia-user-app.
class Country {
  final String self;
  final String name;
  final String countryCode;
  final String currencyCode;
  final double creditCost;

  const Country({
    required this.self,
    required this.name,
    required this.countryCode,
    required this.currencyCode,
    required this.creditCost,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      self: json['self'] as String? ?? '',
      name: json['name'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      currencyCode: json['currencyCode'] as String? ?? '',
      creditCost: (json['creditCost'] as num?)?.toDouble() ?? 0,
    );
  }
}
