import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/auth/token_manager.dart';
import 'core/network/auth_client.dart';
import 'core/locale/locale_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'core/audio/tts_service.dart';
import 'core/audio/stt_service.dart';
import 'core/audio/audio_session_manager.dart';
import 'core/audio/audio_feedback_service.dart';
import 'core/audio/lesson_audio_player_service.dart';
import 'features/course/data/course_repository.dart';

// ==========================================
// PHASE 5 IMPORTS
// ==========================================
import 'features/lesson/domain/repositories/i_lesson_repository.dart';
import 'features/lesson/data/repositories/lesson_repository_impl.dart';
import 'features/lesson/presentation/state/lesson_cubit.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  // 1. External Packages
  const secureStorage = FlutterSecureStorage();

  // 2. Core Locale Service — must init first so locale is ready before UI
  final localeService = LocaleService(secureStorage);
  await localeService.init();
  locator.registerSingleton<LocaleService>(localeService);

  // 3. Core Audio Services
  final ttsService = TtsService(secureStorage);
  // Do NOT await initTts here completely to prevent blocking the startup for too long,
  // but since we want the preferences loaded early, we just let it be called during splash or home.
  // Actually, localeService is initialized here. we can initialize tts with that locale.
  locator.registerSingleton<TtsService>(ttsService);
  
  // NOTE: We do not call initTts() here because it requires speech rate / language matching
  // which is handled downstream during app boot or home screen load.
  
  locator.registerLazySingleton(() => SttService());
  locator.registerLazySingleton(() => AudioSessionManager());
  locator.registerLazySingleton(() => AudioFeedbackService());
  // Factory: each LessonPlayerScreen gets its own player instance (clean dispose).
  locator.registerFactory(() => LessonAudioPlayerService());

  // 4. Core Auth & Network
  locator.registerLazySingleton(() => TokenManager(secureStorage));

  // Register AuthClient under its own concrete type — no casts needed anywhere.
  locator.registerLazySingleton<AuthClient>(
    () => AuthClient(http.Client(), locator<TokenManager>()),
  );

  // http.Client resolves to the same AuthClient instance.
  locator.registerLazySingleton<http.Client>(() => locator<AuthClient>());

  // 5. Existing Repositories
  locator.registerLazySingleton(
    () => AuthRepository(locator<TokenManager>(), locator<http.Client>()),
  );

  locator.registerLazySingleton(() => CourseRepository());

  // ==========================================
  // 6. PHASE 5: LESSON DATA PIPELINE
  // ==========================================

  // Register Repository First (Data Layer)
  // AuthClient is injected directly (no cast), TokenManager is injected for account_id.
  locator.registerLazySingleton<ILessonRepository>(
    () => LessonRepositoryImpl(
      locator<AuthClient>(), // direct — no cast needed
      locator<TokenManager>(), // needed to resolve account_id for URL
    ),
  );

  // Register Cubit Second (Presentation Layer) - Depends on ILessonRepository
  locator.registerFactory<LessonCubit>(
    () => LessonCubit(locator<ILessonRepository>()),
  );
}
