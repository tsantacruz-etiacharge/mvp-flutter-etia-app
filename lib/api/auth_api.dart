import 'package:dio/dio.dart';
import '../models/auth_tokens.dart';
import '../models/auth_data.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

  Future<AuthTokens> signUp(String email, String password) async {
    await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
    return signIn(email, password);
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

  static AuthData decodeToken(String accessToken) {
    final payload = JwtDecoder.decode(accessToken);
    return AuthData.fromJwt(payload);
  }
}
