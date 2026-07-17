import 'package:dio/dio.dart';
import '../models/company_charger.dart';

class CompanyChargerApi {
  final Dio _dio;

  CompanyChargerApi(this._dio);

  Future<List<CompanyCharger>> getClosest({
    required double lat,
    required double lng,
    bool? showPublic,
    String? user,
    String? company,
  }) async {
    final params = <String, dynamic>{
      'lat': lat,
      'lng': lng,
    };
    if (showPublic != null) params['showPublic'] = showPublic;
    if (user != null) params['user'] = user;
    if (company != null) params['company'] = company;

    final response = await _dio.get(
      '/company-chargers/closest',
      queryParameters: params,
    );

    return (response.data as List<dynamic>)
        .map((e) => CompanyCharger.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
