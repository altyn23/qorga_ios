import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/mood.dart';
import 'package:table_calendar/table_calendar.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Mood page renders main title', (tester) async {
    await pumpScreen(
      tester,
      const MoodPage(baseUrl: 'http://localhost:4000', userId: 'test-user-id'),
    );

    expect(find.text('Көңіл-күй'), findsWidgets);
    expect(find.text('Көңіл-күй күнтізбесі'), findsOneWidget);
    expect(find.byType(TableCalendar), findsOneWidget);
  });

  testWidgets('Mood page renders calendar controls', (tester) async {
    await pumpScreen(
      tester,
      const MoodPage(baseUrl: 'http://localhost:4000', userId: 'test-user-id'),
    );

    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('Mood page shows bottom navigation actions', (tester) async {
    await pumpScreen(
      tester,
      const MoodPage(baseUrl: 'http://localhost:4000', userId: 'test-user-id'),
    );

    expect(find.text('Басты'), findsOneWidget);
    expect(find.text('Чат'), findsOneWidget);
    expect(find.text('Мақалалар'), findsOneWidget);
  });
}
