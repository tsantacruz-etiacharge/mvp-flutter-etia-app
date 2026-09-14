import 'dart:async';

import 'package:dio/dio.dart';

import '../config/env.dart';
import '../utils/app_logger.dart';
import 'auth_api.dart';
import 'reference_api.dart';
import 'company_charger_api.dart';
import 'session_api.dart';
import 'benefit_api.dart';
import 'user_api.dart';

class ApiClient {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  late final Dio dio;
  late final AuthApi authApi;
  late final ReferenceApi referenceApi;
  late final CompanyChargerApi companyChargerApi;
  late final SessionApi sessionApi;
  late final BenefitApi benefitApi;
  late final UserApi userApi;

  String Function()? _authTokenGetter;
  Future<void> Function()? _onUnauthorized;

  /// Single-flight guard: concurrent 401s share one refresh instead of
  /// firing N refresh calls (which caused token races / retry loops).
  Future<void>? _refreshInFlight;
  bool _refreshFailed = false;

  ApiClient({Dio? dioOverride}) {
    dio = dioOverride ??
        Dio(BaseOptions(
          baseUrl: Env.apiBaseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
        ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authTokenGetter?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        AppLogger.debug('${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.debug(
          '${response.requestOptions.method} ${response.requestOptions.uri} '
          '-> ${response.statusCode}',
        );
        handler.next(response);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        AppLogger.warning(
          '${error.requestOptions.method} ${error.requestOptions.uri} '
          '-> $status (${error.type})',
          error.error,
        );

        // Never retry the auth endpoints themselves: a 401 from
        // /auth/refresh or /auth/signin means bad credentials, not an
        // expired access token. Retrying would loop.
        if (status == 401 && _onUnauthorized != null && !_isAuthPath(path)) {
          // Only one retry per request.
          if (error.requestOptions.extra['etia-retried'] == true) {
            return handler.next(error);
          }
          try {
            await _refreshOnce();
            if (_refreshFailed) return handler.next(error);
            final token = _authTokenGetter?.call();
            if (token == null || token.isEmpty) {
              return handler.next(error);
            }
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            error.requestOptions.extra['etia-retried'] = true;
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (_) {
            // Fall through to original error.
          }
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

  bool _isAuthPath(String path) => path.startsWith('/auth/');

  Future<void> _refreshOnce() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final callback = _onUnauthorized;
    if (callback == null) return Future.value();
    _refreshFailed = false;
    final future = callback().then(
      (_) {},
      onError: (_) => _refreshFailed = true,
    ).whenComplete(() => _refreshInFlight = null);
    _refreshInFlight = future;
    return future;
  }

  void setAuthGetter(String Function() getter) {
    _authTokenGetter = getter;
  }

  void setOnUnauthorized(Future<void> Function() callback) {
    _onUnauthorized = callback;
  }
}
