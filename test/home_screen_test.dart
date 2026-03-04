import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/home.dart';
import 'package:qorga_app/news.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Home screen renders app title for user', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      prefs: const {
        'role': 'user',
      },
    );

    expect(find.text('QORGA'), findsOneWidget);
    expect(find.text('Басты'), findsOneWidget);
    expect(find.text('Көңіл-күй'), findsWidgets);
    expect(find.text('Чат'), findsWidgets);
    expect(find.text('Мақалалар'), findsWidgets);
  });

  testWidgets('Home screen shows psychologist bottom tabs only',
      (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      prefs: const {
        'role': 'psychologist',
      },
    );

    expect(find.text('Чаттар'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Көңіл-күй'), findsNothing);
  });

  testWidgets('Home screen user tab navigation opens news tab', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      prefs: const {
        'role': 'user',
      },
    );

    expect(find.text('Жылдам әрекеттер'), findsOneWidget);

    await tester.tap(find.text('Мақалалар').last);
    await tester.pumpAndSettle();

    expect(find.byType(NewsScreen), findsOneWidget);
    expect(find.text('Іздеу'), findsOneWidget);
  });

  testWidgets('Home screen psychologist mode hides drawer', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      prefs: const {
        'role': 'psychologist',
      },
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.drawer, isNull);
    expect(find.text('Психолог панелі'), findsOneWidget);
  });
}
