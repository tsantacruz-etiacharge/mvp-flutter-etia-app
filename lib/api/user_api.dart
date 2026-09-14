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

  /// Mirrors UserApi.create in etia-user-app (api/user/user.api.ts).
  /// dateOfBirth is serialized as YYYY-MM-DD (manual formatting avoids the
  /// UTC day-shift that toISOString() can produce near midnight).
  Future<void> create({
    required String firstName,
    required String lastName,
    required String gender,
    required String countryCode,
    required DateTime dateOfBirth,
  }) async {
    final dob =
        '${dateOfBirth.year.toString().padLeft(4, '0')}-'
        '${dateOfBirth.month.toString().padLeft(2, '0')}-'
        '${dateOfBirth.day.toString().padLeft(2, '0')}';
    await _dio.post('/users', data: {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'countryCode': countryCode,
      'dateOfBirth': dob,
    });
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
