import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'home.dart';
import 'news.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QorgaApp());
}

class QorgaApp extends StatelessWidget {
  const QorgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QORGA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/news': (_) => const NewsScreen(),
      },
    );
  }
}
