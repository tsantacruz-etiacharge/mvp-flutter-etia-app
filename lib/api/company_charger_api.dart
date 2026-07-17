import 'package:dio/dio.dart';
import '../models/company_charger.dart';
import '../models/calculated_cost.dart';
import '../models/pagination.dart';

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

  Future<Pagination<CompanyCharger>> getPaged({
    String? location,
    String? company,
    String? visibility,
    int page = 0,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (location != null) params['location'] = location;
    if (company != null) params['company'] = company;
    if (visibility != null) params['visibility'] = visibility;

    final response = await _dio.get(
      '/company-chargers',
      queryParameters: params,
    );

    return Pagination.fromJson(
      response.data as Map<String, dynamic>,
      CompanyCharger.fromJson,
    );
  }

  Future<CompanyCharger> findBySerial(String serial) async {
    final response = await _dio.get('/company-chargers/$serial');
    return CompanyCharger.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CalculatedCost> calculateCost(CompanyCharger charger) async {
    final response = await _dio.post('${charger.self}/calculate-cost');
    return CalculatedCost.fromJson(response.data as Map<String, dynamic>);
  }
}
