import 'package:dio/dio.dart';
import '../models/benefit.dart';

class BenefitApi {
  final Dio _dio;

  BenefitApi(this._dio);

  Future<List<Benefit>> getAll({String lang = 'es'}) async {
    final response = await _dio.get(
      '/benefits',
      queryParameters: {'lang': lang},
    );

    return (response.data as List<dynamic>)
        .map((e) => Benefit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> activate(Benefit benefit, int dni) async {
    await _dio.post('${benefit.self}/activate', data: {'dni': dni});
  }
}
