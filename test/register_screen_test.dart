import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/login.dart';
import 'package:qorga_app/register.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Register screen renders fields', (tester) async {
    await pumpScreen(tester, const RegisterScreen());

    expect(find.text('Регистрация'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Создать аккаунт'), findsOneWidget);
  });

  testWidgets('Register validation rejects invalid email and weak password',
      (tester) async {
    await pumpScreen(tester, const RegisterScreen());

    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');
    await tester.enterText(find.byType(TextFormField).at(2), '123');

    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Некорректный email'), findsOneWidget);
    expect(find.text('Кемінде 8 таңба болуы керек'), findsOneWidget);
  });

  testWidgets('Register password validator enforces uppercase and symbol',
      (tester) async {
    await pumpScreen(tester, const RegisterScreen());

    await tester.enterText(find.byType(TextFormField).at(1), 'test@mail.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'lowercaseonly123');

    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Кемінде 1 бас әріп (A-Z) қажет'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).at(2), 'Lowercase123');
    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Кемінде 1 арнайы таңба қажет'), findsOneWidget);
  });

  testWidgets('Register screen can navigate to login route', (tester) async {
    await pumpScreenWithApp(
      tester,
      const RegisterScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );

    await tester.tap(find.text('Уже есть аккаунт? Войти'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
