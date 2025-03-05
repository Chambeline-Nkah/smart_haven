import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_haven/core/services/recording_service.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'dart:io' show Platform;
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter services are ready

  await dotenv.load(fileName: ".env"); // ✅ Load dotenv BEFORE using it

  await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',  // ✅ Avoid force unwrap (!)
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // Add other providers if necessary
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    final isDark = brightness == Brightness.dark;

    if (PlatformHelper.isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: isDark
            ? AppTheme.cupertinoDarkTheme
            : AppTheme.cupertinoLightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splash,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialLightTheme, // Light theme with Lexend
      darkTheme: AppTheme.materialDarkTheme, // Dark theme with Lexend
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}

class PlatformHelper {
  static String get platform {
    try {
      if (Platform.isIOS) return 'iOS';
      if (Platform.isAndroid) return 'Android';
      return 'Other';
    } catch (_) {
      return 'Web';
    }
  }

  static bool get isIOS => platform == 'iOS';
  static bool get isAndroid => platform == 'Android';
}
