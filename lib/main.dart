import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'injection_container.dart';
import 'core/auth/token_manager.dart';
import 'core/locale/locale_service.dart';
import 'core/audio/tts_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupDependencies(); 
  
  // Initialise TTS with the user's persisted language
  final localeService = locator<LocaleService>();
  final ttsService = locator<TtsService>();
  await ttsService.initTts(
    languageCode: localeService.current.languageCode,
  );
  // Also force the language again just to be safe
  await ttsService.setLanguage(localeService.current.languageCode);

  // Check session state before launching the UI
  final tokenManager = locator<TokenManager>();
  final hasSession = await tokenManager.hasValidSession();

  runApp(EduVoiceApp(hasSession: hasSession));
}

class EduVoiceApp extends StatelessWidget {
  final bool hasSession;

  const EduVoiceApp({super.key, required this.hasSession});

  @override
  Widget build(BuildContext context) {
    final localeService = locator<LocaleService>();

    return ValueListenableBuilder<Locale>(
      valueListenable: localeService.currentLocaleNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          title: 'EduVoice',
          debugShowCheckedModeBanner: false,

          // ── Localisation ──────────────────────────────────────────
          locale: currentLocale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ── Theme ─────────────────────────────────────────────────
          theme: ThemeData(
            // High Contrast Theme Standard
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          // Authenticated users always start at HomeScreen.
          home: hasSession
              ? const HomeScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}