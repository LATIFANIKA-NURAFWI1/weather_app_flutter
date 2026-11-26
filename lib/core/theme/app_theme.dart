import 'package:flutter/material.dart';

/// Tema aplikasi Cuaca Kita yang mengadopsi Glassmorphic Luxury Dark Theme
/// sesuai dengan spesifikasi desain Tailwind HTML/CSS
class AppTheme {
  AppTheme._();

  // Warna gradien latar belakang utama (Home Screen)
  static const Color skyTop = Color(0xFF3B536E);
  static const Color skyMid = Color(0xFF283C50);
  static const Color skyBottom = Color(0xFF15202D);

  // Warna gradien Search Screen
  static const Color searchTop = Color(0xFF2C3E50);
  static const Color searchMid = Color(0xFF243343);
  static const Color searchBottom = Color(0xFF1A2633);

  // Warna aksen
  static const Color goldAccent = Color(0xFFFFD54F);
  static const Color dangerAccent = Color(0xFFFF6B6B);
  static const Color skyAccent = Color(0xFF7DD3FC);
  static const Color skyLight = Color(0xFFBAE6FD);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: skyBottom,
      colorScheme: const ColorScheme.dark(
        primary: skyAccent,
        secondary: goldAccent,
        surface: skyMid,
        error: dangerAccent,
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}
