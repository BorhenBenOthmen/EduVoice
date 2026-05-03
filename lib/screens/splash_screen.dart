// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../core/auth/token_manager.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Splash screen displayed on cold start.
///
/// Behaviour:
/// 1. Shows the EduVoice SVG logo centred on a high-contrast black background.
/// 2. Announces itself via TTS so visually impaired users know the app launched.
/// 3. After a 3-second timer, checks the persisted session state and navigates
///    to either [HomeScreen] or [LoginScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();


    // Navigate after 1 second based on session state.
    Timer(const Duration(seconds: 1), _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final hasSession = await GetIt.I<TokenManager>().hasValidSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasSession ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE6DA), // Beige background to match logo
      body: Center(
        child: Semantics(
          label: 'EduVoice',
          child: ExcludeSemantics(
            child: Image.asset(
              'assets/images/logo.png',
              width: 250, // Slightly larger than 150, but still centered
            ),
          ),
        ),
      ),
    );
  }
}
