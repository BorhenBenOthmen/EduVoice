import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';

import '../../features/lesson/presentation/screens/lesson_list_screen.dart';
import '../../features/lesson/presentation/state/lesson_cubit.dart';
import '../../features/lesson/data/models/lesson_model.dart';
import '../../features/lesson_player/presentation/smart_lesson_player.dart';

import '../../features/cultural_explorer/presentation/cultural_screen.dart';
import '../../features/cultural_explorer/presentation/state/culture_cubit.dart';

import '../../features/podcast_hub/presentation/podcast_screen.dart';
import '../../features/podcast_hub/presentation/state/podcast_cubit.dart';
import '../../features/podcast_hub/data/models/podcast_model.dart';
import '../../features/podcast_hub/presentation/smart_podcast_player.dart';

import '../../features/radio/presentation/radio_screen.dart';
import '../../features/radio/presentation/state/radio_cubit.dart';
import '../../features/radio/data/models/radio_model.dart';
import '../../features/radio/presentation/smart_radio_player.dart';

import '../../features/settings/presentation/settings_screen.dart';
import '../../features/about/presentation/about_screen.dart';

/// Resolves a backend route string (e.g. "/lessons") to a concrete
/// [MaterialPageRoute] complete with any required BlocProviders.
///
/// The [payload] is the raw JSON list sent alongside the `ui_navigation`
/// command. Individual screens can accept it via their constructor or
/// through [RouteSettings.arguments].
///
/// Returns `null` for unknown routes so the caller can log and skip.
class AppRouteResolver {
  AppRouteResolver._();

  static Route<dynamic>? resolve(String route, dynamic payload) {
    switch (route) {
      case '/lessons':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => BlocProvider(
            create: (_) => locator<LessonCubit>(),
            child: LessonListScreen(initialPayload: payload),
          ),
        );

      case '/culture':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => BlocProvider(
            create: (_) => locator<CultureCubit>(),
            child: CultureScreen(initialPayload: payload),
          ),
        );

      case '/podcasts':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => BlocProvider(
            create: (_) => locator<PodcastCubit>(),
            child: PodcastScreen(initialPayload: payload),
          ),
        );

      case '/radio':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => BlocProvider(
            create: (_) => locator<RadioCubit>(),
            child: RadioScreen(initialPayload: payload),
          ),
        );

      // ── Direct Play Routes ──────────────────────────────────────

      case '/lesson_player':
        if (payload != null && payload is List && payload.isNotEmpty) {
          try {
            final lessonMap = Map<String, dynamic>.from(payload[0]);
            final lesson = LessonModel.fromJson(lessonMap);
            return MaterialPageRoute(
              settings: RouteSettings(name: route, arguments: payload),
              builder: (_) => LessonPlayerScreen(lesson: lesson),
            );
          } catch (e) {
            debugPrint('[AppRouteResolver] Failed to parse lesson for direct play: $e');
          }
        }
        return null;

      case '/podcast_player':
        if (payload != null && payload is List && payload.isNotEmpty) {
          try {
            final podcastMap = Map<String, dynamic>.from(payload[0]);
            final podcast = PodcastModel.fromJson(podcastMap);
            return MaterialPageRoute(
              settings: RouteSettings(name: route, arguments: payload),
              builder: (_) => SmartPodcastPlayer(podcast: podcast),
            );
          } catch (e) {
            debugPrint('[AppRouteResolver] Failed to parse podcast for direct play: $e');
          }
        }
        return null;

      case '/radio_player':
        if (payload != null && payload is List && payload.isNotEmpty) {
          try {
            final radioMap = Map<String, dynamic>.from(payload[0]);
            final emission = RadioModel.fromJson(radioMap);
            return MaterialPageRoute(
              settings: RouteSettings(name: route, arguments: payload),
              builder: (_) => SmartRadioPlayer(emission: emission),
            );
          } catch (e) {
            debugPrint('[AppRouteResolver] Failed to parse radio emission for direct play: $e');
          }
        }
        return null;

      case '/settings':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => const SettingsScreen(),
        );

      case '/about':
        return MaterialPageRoute(
          settings: RouteSettings(name: route, arguments: payload),
          builder: (_) => const AboutScreen(),
        );

      default:
        return null;
    }
  }
}
