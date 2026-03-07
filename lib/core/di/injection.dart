// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';

// Domain
import '../../features/lesson/domain/repositories/i_lesson_repository.dart';
// Data
import '../../features/lesson/data/repositories/lesson_repository_impl.dart';

// Core
import '../network/auth_client.dart';
import '../audio/tts_service.dart';
import '../auth/token_manager.dart';

// State Management
import '../../features/lesson/presentation/state/lesson_cubit.dart';

final sl = GetIt.instance;

void initPhase5() {
  // NOTE: Assuming AuthClient and TtsService are already registered in Phase 3/4.
  // If they are not, they MUST be registered before the repository.
  
  // 1. Register Repository (Data Layer)
  sl.registerLazySingleton<ILessonRepository>(
    () => LessonRepositoryImpl(
      sl<AuthClient>(),
      sl<TtsService>(),
      sl<TokenManager>(),
    ),
  );

  // 2. Register Cubit (Presentation Layer) - Depends on Repository
  sl.registerFactory<LessonCubit>(
    () => LessonCubit(sl<ILessonRepository>()),
  );
}