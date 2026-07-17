import 'package:dio/dio.dart';
import '../config/env.dart';
import 'auth_api.dart';
import 'reference_api.dart';
import 'company_charger_api.dart';
import 'session_api.dart';
import 'benefit_api.dart';
import 'user_api.dart';

class ApiClient {
  late final Dio dio;
  late final AuthApi authApi;
  late final ReferenceApi referenceApi;
  late final CompanyChargerApi companyChargerApi;
  late final SessionApi sessionApi;
  late final BenefitApi benefitApi;
  late final UserApi userApi;

  String Function()? _authTokenGetter;
  Future<void> Function()? _onUnauthorized;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authTokenGetter?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && _onUnauthorized != null) {
          try {
            await _onUnauthorized!.call();
            final token = _authTokenGetter?.call();
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (_) {}
        }
        handler.next(error);
      },
    ));

    authApi = AuthApi(dio);
    referenceApi = ReferenceApi(dio);
    companyChargerApi = CompanyChargerApi(dio);
    sessionApi = SessionApi(dio);
    benefitApi = BenefitApi(dio);
    userApi = UserApi(dio);
  }

  void setAuthGetter(String Function() getter) {
    _authTokenGetter = getter;
  }

  void setOnUnauthorized(Future<void> Function() callback) {
    _onUnauthorized = callback;
  }
}
