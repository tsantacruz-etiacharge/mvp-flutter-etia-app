/// Parsed `serial;connectorID` unlock code (QR or manual entry).
class UnlockCode {
  final String serial;
  final int connectorID;

  const UnlockCode({required this.serial, required this.connectorID});
}

/// Parses a raw unlock code in the `serial;connectorID` format used by
/// etia-user-app (`camera.tsx`, `manual.tsx`: `data.split(';')`).
UnlockCode? parseUnlockCode(String raw) {
  final parts = raw.trim().split(';');
  if (parts.isEmpty) return null;
  final serial = parts[0].trim();
  if (serial.isEmpty) return null;
  var connectorID = 1;
  if (parts.length > 1) {
    final parsed = int.tryParse(parts[1].trim());
    if (parsed == null || parsed <= 0) return null;
    connectorID = parsed;
  }
  return UnlockCode(serial: serial, connectorID: connectorID);
}
