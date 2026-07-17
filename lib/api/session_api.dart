import 'package:dio/dio.dart';
import '../models/charging_session.dart';
import '../models/pagination.dart';

class SessionApi {
  final Dio _dio;

  SessionApi(this._dio);

  Future<Pagination<ChargingSession>> getPaged({
    String? user,
    String? state,
    int page = 0,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (user != null) params['user'] = user;
    if (state != null) params['state'] = state;

    final response = await _dio.get(
      '/charging-sessions',
      queryParameters: params,
    );

    return Pagination.fromJson(
      response.data as Map<String, dynamic>,
      ChargingSession.fromJson,
    );
  }

  Future<void> start({
    required String serial,
    required int connectorID,
    required int limitMinutes,
  }) async {
    await _dio.post('/charging-sessions', data: {
      'serial': serial,
      'connectorID': connectorID,
      'limitMinutes': limitMinutes,
    });
  }

  Future<void> stop(ChargingSession session) async {
    await _dio.post('${session.self}/stop');
  }
}
