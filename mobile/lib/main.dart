import 'package:flutter/material.dart';
import 'legacy/MobileScreen/Login.dart';
import 'legacy/MobileScreen/Register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CozyDorm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // changed theme to match web palette (purple gradient primary)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F3FF), // web bg
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B5CF6),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Color(0xFF8B5CF6)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Do NOT include OwnerDashboardScreen here!
      },
    );
  }
}