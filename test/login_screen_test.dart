import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/forgot_password.dart';
import 'package:qorga_app/login.dart';
import 'package:qorga_app/register.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Login screen renders main fields', (tester) async {
    await pumpScreen(tester, const LoginScreen());

    expect(find.text('Кіру'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Құпиясөз'), findsOneWidget);
    expect(find.text('Құпиясөзді ұмыттыңыз ба?'), findsOneWidget);
  });

  testWidgets('Login validation shows errors on empty submit', (tester) async {
    await pumpScreen(tester, const LoginScreen());

    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(0),
    );
    final passField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );

    expect(emailField.validator!(''), 'Email енгізіңіз');
    expect(passField.validator!(''), 'Құпиясөз енгізіңіз');
  });

  testWidgets('Login validation rejects invalid email and short password',
      (tester) async {
    await pumpScreen(tester, const LoginScreen());

    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(0),
    );
    final passField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );

    expect(emailField.validator!('wrong-email'), 'Дұрыс email жазыңыз');
    expect(passField.validator!('123'), 'Құпиясөз тым қысқа');
  });

  testWidgets('Login screen navigates to forgot password', (tester) async {
    await pumpScreenWithApp(
      tester,
      const LoginScreen(),
    );

    await tester.tap(find.text('Құпиясөзді ұмыттыңыз ба?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('Login screen navigates to register route', (tester) async {
    await pumpScreenWithApp(
      tester,
      const LoginScreen(),
      routes: {
        '/register': (_) => const RegisterScreen(),
      },
    );

    await tester.tap(find.text('Тіркелу'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
