import 'package:flutter_test/flutter_test.dart';
import 'package:etia_maps_prototype/app.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const EtiaMapsApp());
    expect(find.byType(EtiaMapsApp), findsOneWidget);
  });
}
