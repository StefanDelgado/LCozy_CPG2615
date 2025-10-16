import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/student/browse_dorms_map_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/dorm_provider.dart';
import 'providers/booking_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Dorm Management Provider
        ChangeNotifierProvider(create: (_) => DormProvider()),
        
        // Booking Management Provider
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        
        // Additional providers can be added here as needed
      ],
      child: MaterialApp(
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
          '/browse_dorms_map': (context) => const BrowseDormsMapScreen(),
          // Do NOT include OwnerDashboardScreen here!
        },
      ),
    );
  }
}