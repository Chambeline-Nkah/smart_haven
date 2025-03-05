// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'package:smart_haven/presentation/navigation/app_router.dart';
import 'package:smart_haven/presentation/utils/app_prefs.dart';
import 'dart:io' show Platform;
// import '../../../core/services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
    // _navigateNext();
  }

  // Future<void> _navigateNext() async {
  //   // Wait for splash screen duration
  //   await Future.delayed(const Duration(seconds: 4));
  //   if (!mounted) return;

  //   // Check session state
  //   final isFirstTime = await SessionManager.isFirstTime();
  //   if (!mounted) return;

  //   final isLoggedIn = await SessionManager.isLoggedIn();
  //   if (!mounted) return;

  //   // Determine and perform navigation
  //   String route;
  //   if (isFirstTime) {
  //     route = '/onboarding';
  //   } else if (!isLoggedIn) {
  //     route = '/login';
  //   } else {
  //     route = '/dashboard';
  //   }

  //   if (!mounted) return;
  //   Navigator.pushReplacementNamed(context, route);
  // }

  Future<void> _handleNavigation() async {
    // Wait for splash animation/loading
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Check if user has seen onboarding
    final hasSeenOnboarding = await AppPrefs.hasSeenOnboarding();

    if (!mounted) return;

    // Navigate based on onboarding status
    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
    } else {
      // Here you can add additional checks like user authentication status
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    // Common content widget
    Widget content = Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        // Background color
        color: isDark ? const Color(0xFF071212) : Colors.white,
        // Background image
        image: DecorationImage(
          image: AssetImage(
            isDark
                ? 'lib/assets/images/bg_dark_mode.png'
                : 'lib/assets/images/bg_light_mode.png',
          ),
          fit: BoxFit.cover, // Ensure the image covers the entire area
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo and main text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ThemeProvider().isDarkMode
                        ? 'lib/assets/images/logo_dark.png'
                        : 'lib/assets/images/logo_light.png',
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                  ),
                  Transform.translate(
                    offset: const Offset(
                        0, -30), // Adjust this value to control spacing
                    child: _AdaptiveText(
                      'SmartHaven',
                      style: Platform.isIOS
                          ? CupertinoTheme.of(context)
                              .textTheme
                              .navLargeTitleTextStyle
                          : Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Bottom texts
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  _AdaptiveText(
                    'BY',
                    style: (Platform.isIOS
                            ? CupertinoTheme.of(context).textTheme.textStyle
                            : Theme.of(context).textTheme.bodySmall)
                        ?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _AdaptiveText(
                    'NCD',
                    style: (Platform.isIOS
                            ? CupertinoTheme.of(context).textTheme.textStyle
                            : Theme.of(context).textTheme.bodySmall)
                        ?.copyWith(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Return platform-specific scaffold
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: content,
          )
        : Scaffold(
            body: content,
          );
  }
}

// Helper widget for cross-platform text
class _AdaptiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const _AdaptiveText(this.data, {this.style});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Text(
            data,
            style: style,
            textAlign: TextAlign.center,
          )
        : Text(
            data,
            style: style,
            textAlign: TextAlign.center,
          );
  }
}
