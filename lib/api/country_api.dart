import 'package:dio/dio.dart';
import '../models/country.dart';

// Mirrors api/country/country.api.ts in etia-user-app.
class CountryApi {
  final Dio _dio;

  CountryApi(this._dio);

  Future<List<Country>> getAll() async {
    final response = await _dio.get('/countries');
    return (response.data as List<dynamic>)
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
