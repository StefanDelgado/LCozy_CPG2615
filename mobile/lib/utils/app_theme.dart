import 'package:flutter/material.dart';

/// App-wide theme configuration
/// Synced with web application purple/violet theme
class AppTheme {
  // Primary Colors - Darker Purple/Violet theme from web
  static const Color primary = Color(0xFF7C3AED);  // Darker purple (was #8b5cf6)
  static const Color primaryLight = Color(0xFF8B5CF6); // Medium purple
  static const Color primaryDark = Color(0xFF6D28D9); // Very dark purple
  
  // Background Colors
  static const Color background = Color(0xFFF6F3FF); // --bg: #f6f3ff
  static const Color scaffoldBg = Color(0xFFF9F6FB);
  static const Color panel = Color(0xFFFFFFFF); // --panel: #fff
  static const Color cardBg = Color(0xFFEDE9FE); // Light purple for cards
  
  // Sidebar/Header Colors
  static const Color sidebar = Color(0xFFE9D5FF); // Sidebar background
  static const Color sidebarActive = Color(0xFFD8B4FE);
  
  // Text Colors
  static const Color ink = Color(0xFF1F1147); // --ink: #1f1147 (primary text)
  static const Color textDark = Color(0xFF2A174D); // Darker text
  static const Color muted = Color(0xFF7A68B8); // --muted: #7a68b8
  static const Color textLight = Color(0xFF4B3F8A);
  
  // Border Colors
  static const Color border = Color(0xFFEADCFF); // --border: #eadcff
  static const Color borderLight = Color(0xFFE5E7EB);
  
  // Status Colors
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFD8B4FE), Color(0xFFC4B5FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withOpacity(0.07),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 30.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textDark,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textDark,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: ink,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: ink,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: muted,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textLight,
  );
  
  // Button Styles
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
    elevation: 2,
  );
  
  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: primary),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
  );
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: panel,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingLarge,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: panel,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButton,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButton,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
