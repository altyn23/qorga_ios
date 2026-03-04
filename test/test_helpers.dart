import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> pumpScreenWithApp(
  WidgetTester tester,
  Widget screen, {
  Map<String, Object> prefs = const {},
  Map<String, WidgetBuilder> routes = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(
    MaterialApp(
      home: screen,
      routes: routes,
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}
