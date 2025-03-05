// lib/presentation/screens/auth/signup_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'dart:io' show Platform;
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          height: size.height * 0.2,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              'lib/assets/images/bottom_onboard.png',
              fit: BoxFit.contain,
            ),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and App Name
                  Row(
                    children: [
                      Image.asset(
                        ThemeProvider().isDarkMode
                          ? 'lib/assets/images/logo_dark.png'
                          : 'lib/assets/images/logo_light.png',
                        height: 24,
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
                    'Sign Up',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your information',
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
                        _buildInputField(
                          context,
                          label: 'Username',
                          hintText: 'Enter your username',
                          controller: _usernameController,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          context,
                          label: 'Email',
                          hintText: 'Enter your email',
                          controller: _emailController,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          context,
                          label: 'Password',
                          hintText: 'Enter your password',
                          controller: _passwordController,
                          isDark: isDark,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          context,
                          label: 'Confirm Password',
                          hintText: 'Confirm your password',
                          controller: _confirmPasswordController,
                          isDark: isDark,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width:
                                150, // Adjust this value to change button width
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
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
                                      horizontal: 30, vertical: 15),
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
                                          'Get Started',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isDark,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !(isPasswordVisible ?? false),
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Add this to reduce height
            hintText: hintText,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
                width: 2,
              ),
            ),
            filled: false,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ?? false
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = AuthService();
        final user = await authService.signInWithEmailAndPassword(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (user != null && mounted) {
          log('User is not null. Navigating...');
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          log('User is null or mounted is false. Not navigating.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );

          // Clear input fields on error
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
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
}
