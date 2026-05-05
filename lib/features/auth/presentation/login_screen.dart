// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/audio/tts_service.dart';
import '../data/auth_repository.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../notification/presentation/state/notification_cubit.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = GetIt.I<AuthRepository>();
  final _tts = GetIt.I<TtsService>(); 

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      await _tts.speak(l.loginEmptyFields);
      return;
    }

    setState(() => _isLoading = true);
    await _tts.speak(l.loginLoading);

    final success = await _authRepo.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.read<NotificationCubit>().startPolling();
      // Navigate immediately to Home, letting HomeScreen's initState handle the Welcome TTS
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      // Await so the blind user actually hears the error before anything else.
      await _tts.speak(l.loginError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.loginTitle,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: l.loginEmailSemantics,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 24, color: AppTheme.navy),
                  decoration: InputDecoration(
                    labelText: l.loginEmailLabel,
                    labelStyle: const TextStyle(fontSize: 24, color: AppTheme.darkTeal),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.navy, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                label: l.loginPasswordSemantics,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  style: const TextStyle(fontSize: 24, color: AppTheme.navy),
                  decoration: InputDecoration(
                    labelText: l.loginPasswordLabel,
                    labelStyle: const TextStyle(fontSize: 24, color: AppTheme.darkTeal),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.navy, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: l.loginButtonSemantics,
                child: SizedBox(
                  height: 80, // Massive touch target for visually impaired
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkTeal, // High contrast button
                      foregroundColor: AppTheme.cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppTheme.cream)
                        : Text(
                            l.loginButton,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}