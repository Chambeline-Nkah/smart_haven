// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Common colors and gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAC05E),
      Color(0xFFF02D3A),
    ],
  );

  static const primaryColor = Color(0xFFFAC05E);
  static const secondaryColor = Color(0xFF357ABD);
  static const backgroundColor = Color(0xFFFFFFFF);
  static const darkBackgroundColor = Color(0xFF071212);

  // Material Theme Configuration
  static final ThemeData materialLightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Lexend',
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
    ),
    textTheme: _buildTextTheme(isDark: false),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  static final ThemeData materialDarkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Lexend',
    scaffoldBackgroundColor: darkBackgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkBackgroundColor,
    ),
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  // Cupertino Theme Configuration
  static const CupertinoThemeData cupertinoLightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'Lexend',
        color: Color(0xFF1A1A1A),
      ),
    ),
  );

  static const CupertinoThemeData cupertinoDarkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'Lexend',
        color: Colors.white,
      ),
    ),
  );

  // Common text theme for both platforms
  static TextTheme _buildTextTheme({required bool isDark}) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Lexend',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Lexend',
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Lexend',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        fontFamily: 'Lexend',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        fontFamily: 'Lexend',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: textColor,
        fontFamily: 'Lexend',
      ),
    );
  }
}
