enum SessionState { pending, inProgress, finished, canceled }

class LocationMetadata {
  final String name;
  final String address;

  const LocationMetadata({required this.name, required this.address});

  factory LocationMetadata.fromJson(Map<String, dynamic> json) {
    return LocationMetadata(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class ChargingSession {
  final String self;
  final String? charger;
  final String? user;
  final SessionState state;
  final String serial;
  final int connectorID;
  final int energyWh;
  final String timeStart;
  final String? timeStop;
  final int limitMinutes;
  final int credits;
  final LocationMetadata location;

  const ChargingSession({
    required this.self,
    this.charger,
    this.user,
    required this.state,
    required this.serial,
    required this.connectorID,
    required this.energyWh,
    required this.timeStart,
    this.timeStop,
    required this.limitMinutes,
    required this.credits,
    required this.location,
  });

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      self: json['self'] as String,
      charger: json['charger'] as String?,
      user: json['user'] as String?,
      state: _parseState(json['state'] as String? ?? ''),
      serial: json['serial'] as String? ?? '',
      connectorID: (json['connectorID'] as num?)?.toInt() ?? 0,
      energyWh: (json['energyWh'] as num?)?.toInt() ?? 0,
      timeStart: json['timeStart'] as String? ?? '',
      timeStop: json['timeStop'] as String?,
      limitMinutes: (json['limitMinutes'] as num?)?.toInt() ?? 0,
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      location: json['location'] != null
          ? LocationMetadata.fromJson(json['location'] as Map<String, dynamic>)
          : const LocationMetadata(name: '', address: ''),
    );
  }

  static SessionState _parseState(String s) {
    switch (s) {
      case 'in-progress': return SessionState.inProgress;
      case 'finished': return SessionState.finished;
      case 'canceled': return SessionState.canceled;
      default: return SessionState.pending;
    }
  }

  double get energyKwh => energyWh / 1000.0;
}
