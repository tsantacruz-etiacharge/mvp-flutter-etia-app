import 'week_time.dart';

class CompanyLocation {
  final String self;
  final String company;
  final String countryCode;
  final String name;
  final String state;
  final String city;
  final String place;
  final String address;
  final String? additionalText;
  final List<OpeningPeriod> openingHours;
  final double lat;
  final double lng;
  final String? imageUrl;

  const CompanyLocation({
    required this.self,
    required this.company,
    required this.countryCode,
    required this.name,
    required this.state,
    required this.city,
    required this.place,
    required this.address,
    this.additionalText,
    required this.openingHours,
    required this.lat,
    required this.lng,
    this.imageUrl,
  });

  factory CompanyLocation.fromJson(Map<String, dynamic> json) {
    return CompanyLocation(
      self: json['self'] as String,
      company: json['company'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      place: json['place'] as String? ?? '',
      address: json['address'] as String? ?? '',
      additionalText: json['additionalText'] as String?,
      openingHours: (json['openingHours'] as List<dynamic>?)
              ?.map((e) => OpeningPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
