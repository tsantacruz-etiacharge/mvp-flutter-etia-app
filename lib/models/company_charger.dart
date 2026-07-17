import 'charger_connector.dart';

enum Visibility { companyUsers, public }

class CompanyCharger {
  final String self;
  final String company;
  final String location;
  final String serial;
  final int powerKw;
  final String name;
  final String model;
  final Visibility visibility;
  final double lat;
  final double lng;
  final bool online;
  final List<ChargerConnector> connectors;
  final String? iconUrl;

  const CompanyCharger({
    required this.self,
    required this.company,
    required this.location,
    required this.serial,
    required this.powerKw,
    required this.name,
    required this.model,
    required this.visibility,
    required this.lat,
    required this.lng,
    required this.online,
    required this.connectors,
    this.iconUrl,
  });

  factory CompanyCharger.fromJson(Map<String, dynamic> json) {
    return CompanyCharger(
      self: json['self'] as String,
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      serial: json['serial'] as String? ?? '',
      powerKw: (json['powerKw'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      model: json['model'] as String? ?? '',
      visibility: (json['visibility'] as String?) == 'public'
          ? Visibility.public
          : Visibility.companyUsers,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      online: json['online'] as bool? ?? false,
      connectors: (json['connectors'] as List<dynamic>?)
              ?.map((c) => ChargerConnector.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      iconUrl: json['iconUrl'] as String?,
    );
  }

  ChargerStatus get status {
    if (!online) return ChargerStatus.unavailable;
    if (connectors.any((c) => c.error != ChargePointError.noError)) {
      return ChargerStatus.unavailable;
    }
    if (connectors.any((c) =>
        c.status == ChargePointStatus.unavailable ||
        c.status == ChargePointStatus.faulted)) {
      return ChargerStatus.unavailable;
    }
    if (connectors.any((c) => c.status == ChargePointStatus.available)) {
      return ChargerStatus.available;
    }
    return ChargerStatus.occupied;
  }
}

enum ChargerStatus { available, occupied, unavailable }
