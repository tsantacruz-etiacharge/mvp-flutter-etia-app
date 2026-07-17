import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:etia_maps_prototype/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('pt'),
          Locale('fr'),
        ],
        fallbackLocale: const Locale('en'),
        path: 'assets/translations',
        child: const ProviderScope(child: EtiaApp()),
      ),
    );

    expect(find.byType(EtiaApp), findsOneWidget);
  });
}
