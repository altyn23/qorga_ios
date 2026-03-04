import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorga_app/forgot_password.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Forgot password screen renders first step', (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());

    expect(find.text('Құпия сөзді ұмыттыңыз ба?'), findsWidgets);
    expect(find.text('Код жіберу'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('Forgot password validation rejects bad email', (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());

    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    final validator = emailField.validator!;

    expect(validator('invalid-email'), 'Дұрыс email енгізіңіз');
    expect(validator('user@mail.ru'), isNull);
  });

  testWidgets('Forgot password starts from step 1 only', (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());

    expect(
      find.text('1-қадам: Email енгізіп, код сұратыңыз'),
      findsOneWidget,
    );
    expect(find.text('Код'), findsNothing);
    expect(find.text('Жаңа құпия сөз'), findsNothing);
    expect(find.text('Жаңа құпия сөзді растаңыз'), findsNothing);

  });

  testWidgets('Forgot password email field validator rejects empty input',
      (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());
    final emailField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    final validator = emailField.validator!;

    expect(validator(''), 'Дұрыс email енгізіңіз');
  });
}
