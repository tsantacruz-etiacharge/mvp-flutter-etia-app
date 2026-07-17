import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/charging_session.dart';
import 'auth_provider.dart';

final sessionProvider =
    FutureProvider.autoDispose<ChargingSession?>((ref) async {
  final auth = ref.watch(authProvider);
  final userRef = auth.userRef;
  if (userRef == null) return null;

  final api = ref.read(apiClientProvider);
  final page = await api.sessionApi.getPaged(
    user: userRef,
    state: 'in-progress',
    pageSize: 1,
  );

  return page.data.isNotEmpty ? page.data.first : null;
});
