import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/help.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Help screen renders', (tester) async {
    await pumpScreen(tester, const HelpScreen());

    expect(find.text('Жедел көмек'), findsWidgets);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('ШҰҒЫЛ ҚЫЗМЕТТЕР'), findsOneWidget);
    expect(find.text('СЕНІМ ТЕЛЕФОНДАРЫ (ПСИХОЛОГИЯЛЫҚ КӨМЕК)'), findsOneWidget);
  });

  testWidgets('Help screen contains emergency numbers', (tester) async {
    await pumpScreen(tester, const HelpScreen());

    expect(find.text('101'), findsOneWidget);
    expect(find.text('102'), findsOneWidget);
    expect(find.text('103'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('111'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('116111'), findsOneWidget);
  });
}
