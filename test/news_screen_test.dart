import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/news.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('News screen renders search UI', (tester) async {
    await pumpScreen(tester, const NewsScreen());

    expect(find.text('Мақалалар'), findsWidgets);
    expect(find.text('Іздеу'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('психология подростков буллинг стресс'), findsOneWidget);
  });

  testWidgets('News search field accepts query', (tester) async {
    await pumpScreen(tester, const NewsScreen());

    await tester.enterText(find.byType(TextField).first, 'кибербуллинг');
    expect(find.text('кибербуллинг'), findsOneWidget);
  });

  testWidgets('News screen keeps search action visible after submit',
      (tester) async {
    await pumpScreen(tester, const NewsScreen());

    await tester.enterText(find.byType(TextField).first, 'поддержка подростков');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Іздеу'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
