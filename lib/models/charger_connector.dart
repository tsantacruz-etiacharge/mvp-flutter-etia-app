enum ConnectorType { type2, ccs2 }

enum ChargePointStatus {
  available,
  preparing,
  charging,
  suspendedEVSE,
  suspendedEV,
  finishing,
  reserved,
  unavailable,
  faulted,
}

enum ChargePointError {
  noError,
  connectorLockFailure,
  evCommunicationError,
  groundFailure,
  highTemperature,
  internalError,
  localListConflict,
  otherError,
  overCurrentFailure,
  overVoltage,
  powerMeterFailure,
  powerSwitchFailure,
  readerFailure,
  resetFailure,
  underVoltage,
  weakSignal,
}

class ChargerConnector {
  final int connectorID;
  final ConnectorType type;
  final ChargePointStatus status;
  final ChargePointError error;
  final String timestamp;

  const ChargerConnector({
    required this.connectorID,
    required this.type,
    required this.status,
    required this.error,
    required this.timestamp,
  });

  factory ChargerConnector.fromJson(Map<String, dynamic> json) {
    return ChargerConnector(
      connectorID: json['connectorID'] as int,
      type: _parseConnectorType(json['type'] as String),
      status: _parseStatus(json['status'] as String),
      error: _parseError(json['error'] as String),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  static ConnectorType _parseType(String s) {
    switch (s) {
      case 'type2': return ConnectorType.type2;
      case 'ccs2': return ConnectorType.ccs2;
      default: return ConnectorType.type2;
    }
  }

  static ConnectorType _parseConnectorType(String s) => _parseType(s);

  static ChargePointStatus _parseStatus(String s) {
    return ChargePointStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ChargePointStatus.unavailable,
    );
  }

  static ChargePointError _parseError(String s) {
    return ChargePointError.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ChargePointError.noError,
    );
  }
}
