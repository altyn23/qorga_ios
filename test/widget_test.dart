import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qorga_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QorgaApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(QorgaApp), findsOneWidget);
    expect(find.text('Кіру'), findsWidgets);
    expect(find.text('Тіркелу'), findsOneWidget);
  });
}
