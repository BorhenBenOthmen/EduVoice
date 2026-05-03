import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'injection_container.dart';
import 'core/auth/token_manager.dart';
import 'core/locale/locale_service.dart';
import 'core/audio/tts_service.dart';
import 'screens/splash_screen.dart';
import 'features/voice_commander/presentation/widgets/wake_gesture_detector.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/notification/presentation/state/notification_cubit.dart';
import 'features/notification/presentation/state/notification_state.dart';
import 'features/notification/presentation/widgets/notification_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  // Initialise TTS with the user's persisted language
  final localeService = locator<LocaleService>();
  final ttsService = locator<TtsService>();
  await ttsService.initTts(languageCode: localeService.current.languageCode);
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

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Controls whether the accessibility tree is active.
  /// Set to `false` before a locale change (LTR↔RTL) to prevent TalkBack
  /// from crashing when accessibility nodes are rebuilt.
  static final ValueNotifier<bool> semanticsEnabled = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final localeService = locator<LocaleService>();

    return ValueListenableBuilder<bool>(
      valueListenable: semanticsEnabled,
      builder: (context, isSemanticsEnabled, _) {
        return ExcludeSemantics(
          // When false → all accessibility nodes are removed from tree,
          // TalkBack has nothing to reference, so locale rebuild is safe.
          excluding: !isSemanticsEnabled,
          child: ValueListenableBuilder<Locale>(
            valueListenable: localeService.currentLocaleNotifier,
            builder: (context, currentLocale, _) {
              return MaterialApp(
                navigatorKey: navigatorKey,
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

                builder: (context, child) {
                  return BlocProvider(
                    create: (_) {
                      final cubit = locator<NotificationCubit>();
                      if (hasSession) {
                        cubit.startPolling();
                      }
                      return cubit;
                    },
                    child: BlocListener<NotificationCubit, NotificationState>(
                      listener: (context, state) async {
                        if (state is NotificationNewReceived) {
                          final overlayState =
                              navigatorKey.currentState?.overlay;
                          if (overlayState != null) {
                            NotificationOverlay.show(
                              overlayState,
                              state.notification.note,
                            );
                          } else {
                            debugPrint(
                              'Failed to get overlay context for notification banner',
                            );
                          }

                          final lContext = navigatorKey.currentState?.context;
                          final announcement = lContext != null
                              ? AppLocalizations.of(
                                      lContext,
                                    )?.notificationArrived ??
                                    "Une notification est survenue"
                              : "Une notification est survenue";

                          // Delay briefly so TalkBack doesn't overlap immediately
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          locator<TtsService>().speakNotification(
                            announcement,
                            state.notification.note,
                          );
                        }
                      },
                      child: WakeGestureDetector(child: child!),
                    ),
                  );
                },

                // SplashScreen handles session check and routes to
                // HomeScreen or LoginScreen after a 3-second delay.
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
