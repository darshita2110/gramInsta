// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/feed_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GraminstaApp(),
    ),
  );
}

class GraminstaApp extends StatelessWidget {
  const GraminstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graminsta',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const SplashScreen(),
    );
  }

  // ---------------------------------------------------------------------------
  // Light theme — matches Instagram's exact light palette
  // ---------------------------------------------------------------------------
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Color(0xFF0095F6),
        secondary: Color(0xFF0095F6),
      ),
      dividerColor: const Color(0xFFDBDBDB),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF262626), fontSize: 14),
        bodyMedium: TextStyle(color: Color(0xFF262626), fontSize: 13.5),
        bodySmall: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF262626),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF262626),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme — matches Instagram's exact dark palette
  // ---------------------------------------------------------------------------
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        surface: Colors.black,
        primary: Color(0xFF0095F6),
        secondary: Color(0xFF0095F6),
      ),
      dividerColor: const Color(0xFF262626),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 14),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 13.5),
        bodySmall: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF262626),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}