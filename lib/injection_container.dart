import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/auth/token_manager.dart';
import 'core/network/auth_client.dart';
import 'core/locale/locale_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'core/audio/tts_service.dart';

import 'core/audio/lesson_audio_player_service.dart';
import 'features/voice_commander/data/gemini_routing_service.dart';

// ==========================================
// PHASE 5 IMPORTS
// ==========================================
import 'features/lesson/domain/repositories/i_lesson_repository.dart';
import 'features/lesson/data/repositories/lesson_repository_impl.dart';
import 'features/lesson/presentation/state/lesson_cubit.dart';

import 'features/cultural_explorer/domain/repositories/i_culture_repository.dart';
import 'features/cultural_explorer/data/repositories/culture_repository_impl.dart';
import 'features/cultural_explorer/presentation/state/culture_cubit.dart';

import 'features/podcast_hub/domain/repositories/i_podcast_repository.dart';
import 'features/podcast_hub/data/repositories/podcast_repository_impl.dart';
import 'features/podcast_hub/presentation/state/podcast_cubit.dart';

import 'features/radio/domain/repositories/i_radio_repository.dart';
import 'features/radio/data/repositories/radio_repository_impl.dart';
import 'features/radio/presentation/state/radio_cubit.dart';

import 'features/notification/domain/repositories/i_notification_repository.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/presentation/state/notification_cubit.dart';
import 'features/notification/data/datasources/local_notification_storage.dart';
import 'features/notification/presentation/state/notification_list_cubit.dart';

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
  locator.registerSingleton<TtsService>(ttsService);
  
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

  // ==========================================
  // CULTURE MODULE PIPELINE
  // ==========================================
  locator.registerLazySingleton<ICultureRepository>(
    () => CultureRepositoryImpl(
      locator<AuthClient>(),
      locator<TokenManager>(),
    ),
  );

  locator.registerFactory<CultureCubit>(
    () => CultureCubit(locator<ICultureRepository>()),
  );

  // ==========================================
  // PODCAST MODULE PIPELINE
  // ==========================================
  locator.registerLazySingleton<IPodcastRepository>(
    () => PodcastRepositoryImpl(
      locator<AuthClient>(),
      locator<TokenManager>(),
    ),
  );

  locator.registerFactory<PodcastCubit>(
    () => PodcastCubit(locator<IPodcastRepository>()),
  );

  // ==========================================
  // RADIO MODULE PIPELINE
  // ==========================================
  locator.registerLazySingleton<IRadioRepository>(
    () => RadioRepositoryImpl(
      locator<AuthClient>(),
      locator<TokenManager>(),
    ),
  );

  locator.registerFactory<RadioCubit>(
    () => RadioCubit(locator<IRadioRepository>()),
  );

  // ==========================================
  // VOICE COMMANDER PIPELINE
  // ==========================================
  locator.registerLazySingleton<GeminiRoutingService>(
    () => GeminiRoutingService(locator<TokenManager>()),
  );

  // ==========================================
  // NOTIFICATION MODULE PIPELINE
  // ==========================================
  locator.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      locator<AuthClient>(),
      locator<TokenManager>(),
    ),
  );

  locator.registerLazySingleton<LocalNotificationStorage>(
    () => LocalNotificationStorage(secureStorage),
  );

  locator.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(locator<INotificationRepository>(), locator<LocalNotificationStorage>()),
  );

  locator.registerFactory<NotificationListCubit>(
    () => NotificationListCubit(locator<LocalNotificationStorage>()),
  );
}
