import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/psychology_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Psychology test screen renders app bar', (tester) async {
    await pumpScreen(
      tester,
      const PsychologyTestScreen(
        baseUrl: 'http://localhost:4000',
        userId: 'test-user-id',
      ),
    );

    expect(find.text('Психологиялық тест'), findsWidgets);
  });

  testWidgets('Psychology test screen shows loading or error state',
      (tester) async {
    await pumpScreen(
      tester,
      const PsychologyTestScreen(
        baseUrl: 'http://localhost:4000',
        userId: 'test-user-id',
      ),
    );

    final hasLoader = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasError = find
        .text('Сұрақтарды жүктеу кезінде қате болды.')
        .evaluate()
        .isNotEmpty;
    expect(hasLoader || hasError, isTrue);
  });

  testWidgets('Psychology test screen handles load failure state',
      (tester) async {
    await pumpScreen(
      tester,
      const PsychologyTestScreen(
        baseUrl: 'http://localhost:4000',
        userId: 'test-user-id',
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.text('Сұрақтарды жүктеу кезінде қате болды.'),
      findsOneWidget,
    );
  });
}
