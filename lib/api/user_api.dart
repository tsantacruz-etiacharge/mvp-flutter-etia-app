import 'package:dio/dio.dart';
import '../models/user_company.dart';

class UserApi {
  final Dio _dio;

  UserApi(this._dio);

  Future<List<UserCompany>> getCompanies(String userRef) async {
    final response = await _dio.get('$userRef/companies');
    return (response.data as List<dynamic>)
        .map((e) => UserCompany.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
