// lib/presentation/screens/auth/login_screen.dart
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'dart:io' show Platform;
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Platform.isIOS
          ? CupertinoPageScaffold(child: _buildContent())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        SizedBox.expand(
          // Ensure background fills entire space
          child: Image.asset(
            isDark
                ? 'lib/assets/images/bg_dark_mode.png'
                : 'lib/assets/images/bg_light_mode.png',
            fit: BoxFit.cover,
          ),
        ),
        // Top decoration
        Positioned(
          top: 0,
          right: 0,
          width: size.width * 0.3,
          child: Image.asset(
            'lib/assets/images/top_onboard.png',
            fit: BoxFit.contain,
          ),
        ),
        // Bottom decoration
        Positioned(
          bottom: 0,
          left: 0,
          width: size.width * 0.3,
          child: Image.asset(
            'lib/assets/images/bottom_onboard.png',
            fit: BoxFit.contain,
          ),
        ),
        // Main content
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and App Name
                    Column(
                      children: [
                        Image.asset(
                          ThemeProvider().isDarkMode
                              ? 'lib/assets/images/logo_dark.png'
                              : 'lib/assets/images/logo_light.png',
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'SmartHaven',
                          style: Platform.isIOS
                              ? CupertinoTheme.of(context)
                                  .textTheme
                                  .navTitleTextStyle
                                  .copyWith(fontSize: 16)
                              : Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Login',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your credentials',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8), // Add this to reduce height
                              hintText: 'Enter your username',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              filled: false,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Password',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8), // Add this to reduce height
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              filled: false,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              )
                            : Image.asset(
                                'lib/assets/images/google_icon.png',
                                height: 24,
                              ),
                        label: Text(
                          _isLoading ? 'Signing in...' : 'Login with Google',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }

      // try {
      //   final authService = AuthService();
      //   final user = await authService.loginWithEmailAndPassword(
      //     // username: _usernameController.text,
      //     email: _usernameController.text,
      //     password: _passwordController.text,
      //   );

      //   if (user != null && mounted) {
      //     Navigator.pushReplacementNamed(context, '/dashboard');
      //   }
      // } catch (e) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(e.toString())),
      //     );
      //   }
      // } finally {
      //   if (mounted) {
      //     setState(() {
      //       _isLoading = false;
      //     });
      //   }
      // }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final user = await authService
          .signInWithGoogle(); // signInWithGoogle returns User?

      if (mounted) {
        if (user != null) {
          // Successfully signed in
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // User cancelled the sign-in flow or it failed silently
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in cancelled or failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
