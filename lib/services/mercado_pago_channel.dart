import 'package:flutter/services.dart';

/// Bridge to the native Mercado Pago CoreMethods SDKs (Android Compose +
/// iOS UIKit forms). Ported from prueba-flutter-MP
/// (lib/core/services/mercado_pago_channel.dart); only the channel name
/// changed to the production application id.
///
/// Scope (same as the proof of concept): card tokenization only. The token
/// must be charged backend-side (POST /v1/payments); there is no backend
/// endpoint for that yet, so the token is kept in memory and never shown
/// or logged.
class MercadoPagoChannel {
  static const _channel = MethodChannel('io.etiaapp.app/mercado_pago');

  const MercadoPagoChannel();

  /// Opens the native card form and resolves with the card token.
  /// Throws [MercadoPagoException] on validation/network errors or when
  /// the user cancels ([MercadoPagoException.code] == 'MP_CANCELLED').
  Future<String> createCardToken({
    required String publicKey,
    String countryCode = 'AR',
    String? identificationNumber,
    String identificationType = 'DNI',
  }) async {
    try {
      final token = await _channel.invokeMethod<String>(
        'createCardToken',
        {
          'publicKey': publicKey,
          'countryCode': countryCode,
          if (identificationNumber != null)
            'identificationNumber': identificationNumber,
          'identificationType': identificationType,
        },
      );
      if (token == null || token.isEmpty) {
        throw const MercadoPagoException('EMPTY_TOKEN', 'Empty token received');
      }
      return token;
    } on PlatformException catch (e) {
      throw MercadoPagoException(e.code, e.message ?? 'Platform error');
    } catch (e) {
      throw MercadoPagoException('UNKNOWN', e.toString());
    }
  }
}

class MercadoPagoException implements Exception {
  final String code;
  final String message;

  const MercadoPagoException(this.code, this.message);

  bool get cancelled => code == 'MP_CANCELLED';

  @override
  String toString() => 'MercadoPagoException($code): $message';
}
