import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_company.dart';
import 'auth_provider.dart';

final companiesProvider = FutureProvider<List<UserCompany>>((ref) async {
  final auth = ref.watch(authProvider);
  final userRef = auth.userRef;
  if (userRef == null) return const [];

  final api = ref.read(apiClientProvider);
  return api.userApi.getCompanies(userRef);
});
