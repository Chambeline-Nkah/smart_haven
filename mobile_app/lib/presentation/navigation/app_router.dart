// lib/presentation/navigation/app_router.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_haven/presentation/screens/auth/login_screen.dart';
import 'package:smart_haven/presentation/screens/auth/signup_screen.dart';
import 'package:smart_haven/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:smart_haven/presentation/screens/history/history_screen.dart';
import 'package:smart_haven/presentation/screens/record/record_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String record = '/record';
  static const String history = '/history';

  static bool _isAtDashboard = false;
  static DateTime? _lastBackPressed;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    _isAtDashboard = settings.name == dashboard;
    bool canPop = true;

    Widget Function(BuildContext) builder;

    switch (settings.name) {
      case splash:
        builder = (_) => const SplashScreen();
        break;
      case onboarding:
        builder = (_) => const OnboardingScreen();
        break;
      case signup:
        builder = (_) => const SignupScreen();
        break;
      case login:
        builder = (_) => const LoginScreen();
        break;
      case dashboard:
        builder = (_) => const DashboardScreen();
        break;
      case record:
        builder = (_) => const RecordScreen();
        break;
      case history:
        builder = (_) => const HistoryScreen();
        break;
      default:
        builder = (_) => _placeholderScreen('404 - Not Found');
    }

    return _buildRoute(
      Builder(
        builder: (context) => PopScope(
          canPop: false, // Set to false for all screens
          onPopInvoked: (didPop) async {
            if (didPop) return;

            if (settings.name == dashboard) {
              await _showExitConfirmation(context);
            } else {
              // Navigate back to dashboard for all other screens
              Navigator.of(context).pushReplacementNamed(dashboard);
            }
          },
          child: builder(context),
        ),
      ),
    );
  }

  static Future<void> _showExitConfirmation(BuildContext context) async {
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      );
    }
  }

  static PageRoute _buildRoute(Widget screen) {
    return Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => screen)
        : PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
  }

  static Widget _placeholderScreen(String text) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Placeholder'),
            ),
            child: Center(child: Text(text)),
          )
        : Scaffold(
            appBar: AppBar(title: const Text('Placeholder')),
            body: Center(child: Text(text)),
          );
  }
}
