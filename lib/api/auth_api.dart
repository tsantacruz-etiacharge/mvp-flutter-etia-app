import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/auth_tokens.dart';
import '../models/auth_data.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthTokens> signIn(String email, String password) async {
    final response = await _dio.post(
      '/auth/signin',
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> signUp(String email, String password) async {
    await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      options: Options(
        headers: {'Authorization': 'Bearer $refreshToken'},
      ),
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> sendEmailVerification(String email) async {
    await _dio.post(
      '/auth/verify-email',
      data: {'email': email},
    );
  }

  Future<void> confirmEmailVerification(String email, String code) async {
    await _dio.post(
      '/auth/verify-email/confirm',
      data: {'email': email, 'code': code},
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _dio.post(
      '/auth/reset-password',
      data: {'email': email},
    );
  }

  Future<void> checkPasswordReset(String email, String code) async {
    await _dio.put(
      '/auth/reset-password/check',
      data: {'email': email, 'code': code},
    );
  }

  Future<void> confirmPasswordReset(
    String email,
    String code,
    String password,
  ) async {
    await _dio.post(
      '/auth/reset-password/confirm',
      data: {'email': email, 'code': code, 'password': password},
    );
  }

  Future<void> changePassword(
    String email,
    String password,
    String oldPassword,
  ) async {
    await _dio.post(
      '/auth/change-password',
      data: {
        'email': email,
        'password': password,
        'oldPassword': oldPassword,
      },
    );
  }

  static AuthData decodeToken(String accessToken) {
    final payload = JwtDecoder.decode(accessToken);
    return AuthData.fromJwt(payload);
  }
}
