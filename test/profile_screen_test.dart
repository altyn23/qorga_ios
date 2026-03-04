import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/profile.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Profile screen renders for user', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      prefs: const {
        'role': 'user',
      },
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Профиль'), findsWidgets);
    expect(find.text('Қараңғы режим'), findsOneWidget);
    expect(find.text('Хабарландырулар'), findsOneWidget);
    expect(find.text('Көңіл-күй статистикасы'), findsOneWidget);
  });

  testWidgets('Profile psychologist mode hides mood stats card',
      (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      prefs: const {
        'role': 'psychologist',
      },
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Көңіл-күй статистикасы'), findsNothing);
  });

  testWidgets('Profile shows security and logout sections', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      prefs: const {'role': 'user'},
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.scrollUntilVisible(
      find.text('Қауіпсіздік'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Шығу'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Қауіпсіздік'), findsOneWidget);
    expect(find.text('Шығу'), findsOneWidget);
  });

  testWidgets('Profile toggles are present and interactive', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      prefs: const {'role': 'user'},
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.scrollUntilVisible(
      find.byType(Switch).first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final notificationSwitch = find.byType(Switch).first;
    await tester.tap(notificationSwitch);
    await tester.pumpAndSettle();

    expect(find.text('Хабарландырулар'), findsOneWidget);
    expect(find.text('Қараңғы режим'), findsOneWidget);
  });
}
