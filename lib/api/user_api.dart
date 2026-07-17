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

  Future<void> update(String userSelf, Map<String, dynamic> dto) async {
    await _dio.put(userSelf, data: dto);
  }

  Future<void> addCompany(String userSelf, String inviteCode) async {
    await _dio.post(
      '$userSelf/companies',
      data: {'inviteCode': inviteCode},
      options: Options(
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) || status == 400),
      ),
    );
  }
}
