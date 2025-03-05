// Onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
// import 'package:smart_haven/presentation/navigation/app_router.dart';
import 'package:smart_haven/presentation/utils/app_prefs.dart';
import 'dart:io' show Platform;
import '../../../core/services/session_manager.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Welcome to SmartHaven",
      description:
          "Did you know you could monitor the health of your chickens from a distance?",
    ),
    OnboardingContent(
      title: "Features Highlight",
      description:
          "With the use of accurate voice sensors and AI, monitor the health of your poultry 24h/7",
    ),
    OnboardingContent(
      title: "Get Started",
      description:
          "But before we get you started, we will need a little information",
    ),
  ];

  void _nextPage() {
    if (_currentPage == _contents.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await SessionManager.setFirstTime(false);
    await AppPrefs.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    Widget content = Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDark
                ? 'lib/assets/images/bg_dark_mode.png'
                : 'lib/assets/images/bg_light_mode.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'lib/assets/images/top_onboard.png',
              width: size.width * 0.3,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'lib/assets/images/bottom_onboard.png',
              width: size.width * 0.3,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Logo with reduced size
                      Image.asset(
                       ThemeProvider().isDarkMode
                          ? 'lib/assets/images/logo_dark.png'
                          : 'lib/assets/images/logo_light.png',
                        height:
                            24, // Reduce the height of the logo (you can adjust this value)
                      ),
                      const SizedBox(width: 10),
                      // Text with smaller font size
                      Text(
                        'SmartHaven',
                        style: Platform.isIOS
                            ? CupertinoTheme.of(context)
                                .textTheme
                                .navTitleTextStyle
                                .copyWith(
                                    fontSize: 16) // Reduced font size for iOS
                            : Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    fontSize:
                                        16), // Reduced font size for Android
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _contents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _contents[index].title.toUpperCase(),
                              style: (Platform.isIOS
                                      ? CupertinoTheme.of(context)
                                          .textTheme
                                          .navTitleTextStyle
                                      : Theme.of(context).textTheme.titleLarge)
                                  ?.copyWith(
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: (Platform.isIOS
                                        ? CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                        : Theme.of(context)
                                            .textTheme
                                            .headlineMedium)
                                    ?.copyWith(
                                  fontSize: 32,
                                ),
                                children: _currentPage == 0
                                    ? [
                                        const TextSpan(
                                            text:
                                                'Did you know you could monitor the '),
                                        TextSpan(
                                          text: 'health ',
                                          style: TextStyle(
                                              color: Colors.green.shade600),
                                        ),
                                        const TextSpan(
                                            text: 'of your chickens from '),
                                        TextSpan(
                                          text: 'a distance',
                                          style: TextStyle(
                                              foreground: Paint()
                                                ..shader = AppTheme
                                                    .primaryGradient
                                                    .createShader(
                                                  const Rect.fromLTWH(
                                                      0, 0, 250, 70),
                                                )),
                                        ),
                                        const TextSpan(text: '?'),
                                      ]
                                    : _currentPage == 1
                                        ? [
                                            const TextSpan(
                                                text:
                                                    'With the use of accurate voice sensors and'),
                                            TextSpan(
                                              text: ' AI',
                                              style: TextStyle(
                                                  color: Colors.green.shade600),
                                            ),
                                            const TextSpan(
                                                text:
                                                    ' monitor the health of your poultry '),
                                            TextSpan(
                                              text: '24h/7.',
                                              style: TextStyle(
                                                  foreground: Paint()
                                                    ..shader = AppTheme
                                                        .primaryGradient
                                                        .createShader(
                                                      const Rect.fromLTWH(
                                                          0, 0, 400, 70),
                                                    )),
                                            ),
                                          ]
                                        : [
                                            const TextSpan(
                                                text:
                                                    'But before we get you started, we will need a little '),
                                            TextSpan(
                                              text: 'information.',
                                              style: TextStyle(
                                                  foreground: Paint()
                                                    ..shader = AppTheme
                                                        .primaryGradient
                                                        .createShader(
                                                      const Rect.fromLTWH(
                                                          0, 0, 400, 70),
                                                    )),
                                            ),
                                          ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _contents.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: _nextPage,
                            child: Icon(
                              _currentPage == _contents.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(child: content)
        : Scaffold(body: content);
  }
}

class OnboardingContent {
  final String title;
  final String description;

  OnboardingContent({
    required this.title,
    required this.description,
  });
}
