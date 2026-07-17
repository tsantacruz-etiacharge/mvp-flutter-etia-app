import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('pt'),
        Locale('fr'),
      ],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      saveLocale: true,
      child: const ProviderScope(child: EtiaApp()),
    ),
  );
}
