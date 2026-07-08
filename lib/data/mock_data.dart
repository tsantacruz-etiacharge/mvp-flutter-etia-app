import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ChargerStatus { available, occupied, unavailable }

class MockCharger {
  final String id;
  final String name;
  final LatLng position;
  final int powerKw;
  final ChargerStatus status;
  final String address;

  const MockCharger({
    required this.id,
    required this.name,
    required this.position,
    required this.powerKw,
    required this.status,
    required this.address,
  });
}

final List<MockCharger> mockChargers = [
  const MockCharger(
    id: '1',
    name: 'ETIA Palermo',
    position: LatLng(-34.5885, -58.4206),
    powerKw: 22,
    status: ChargerStatus.available,
    address: 'Av. Santa Fe 3456, Palermo',
  ),
  const MockCharger(
    id: '2',
    name: 'ETIA Recoleta',
    position: LatLng(-34.5875, -58.3930),
    powerKw: 50,
    status: ChargerStatus.occupied,
    address: 'Junín 1234, Recoleta',
  ),
  const MockCharger(
    id: '3',
    name: 'ETIA San Telmo',
    position: LatLng(-34.6230, -58.3720),
    powerKw: 11,
    status: ChargerStatus.available,
    address: 'Defensa 789, San Telmo',
  ),
  const MockCharger(
    id: '4',
    name: 'ETIA Puerto Madero',
    position: LatLng(-34.6150, -58.3640),
    powerKw: 150,
    status: ChargerStatus.unavailable,
    address: 'Alicia Moreau de Justo 500',
  ),
  const MockCharger(
    id: '5',
    name: 'ETIA Belgrano',
    position: LatLng(-34.5610, -58.4540),
    powerKw: 22,
    status: ChargerStatus.available,
    address: 'Cabildo 2100, Belgrano',
  ),
  const MockCharger(
    id: '6',
    name: 'ETIA Almagro',
    position: LatLng(-34.6000, -58.4170),
    powerKw: 30,
    status: ChargerStatus.occupied,
    address: 'Rivadavia 4500, Almagro',
  ),
  const MockCharger(
    id: '7',
    name: 'ETIA Flores',
    position: LatLng(-34.6280, -58.4430),
    powerKw: 22,
    status: ChargerStatus.available,
    address: 'Rivadavia 6800, Flores',
  ),
];
