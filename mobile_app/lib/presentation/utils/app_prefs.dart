import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }
}
