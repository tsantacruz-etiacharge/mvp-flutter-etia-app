import 'package:dio/dio.dart';

class ReferenceApi {
  final Dio _dio;

  ReferenceApi(this._dio);

  Future<T> findByReference<T>(
    String reference,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _dio.get(reference);
    return fromJson(response.data as Map<String, dynamic>);
  }
}
