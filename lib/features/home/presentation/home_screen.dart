import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/tts_service.dart';
import '../../../injection_container.dart';
import '../../../features/lesson/presentation/state/lesson_cubit.dart';
import '../../../features/lesson/presentation/screens/lesson_list_screen.dart';
import '../../../features/cultural_explorer/presentation/cultural_screen.dart';
import '../../../features/cultural_explorer/presentation/state/culture_cubit.dart';
import '../../../features/podcast_hub/presentation/podcast_screen.dart';
import '../../../features/podcast_hub/presentation/state/podcast_cubit.dart';
import '../../../features/radio/presentation/radio_screen.dart';
import '../../../features/radio/presentation/state/radio_cubit.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/about/presentation/about_screen.dart';
import '../../../features/notification/presentation/screens/notification_screen.dart';
import '../../../features/notification/presentation/state/notification_list_cubit.dart';
import '../../../features/profile/presentation/profile_screen.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(l.homeCatalogueTitle),
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            Semantics(
              label: l.homeNotificationSemantics,
              button: true,
              excludeSemantics: true,
              child: IconButton(
                onPressed: () {
                  locator<TtsService>().speak(l.notificationOpening);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => locator<NotificationListCubit>(),
                        child: const NotificationScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
            Semantics(
              label: l.profileTitle,
              button: true,
              excludeSemantics: true,
              child: IconButton(
                onPressed: () {
                  locator<TtsService>().speak(l.profileTitle);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.purpleAccent,
                ),
              ),
            ),
            Semantics(
              label: l.homeSettingsSemantics,
              button: true,
              excludeSemantics: true,
              child: IconButton(
                onPressed: () {
                  locator<TtsService>().speak(l.homeOpeningSettings);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.amberAccent,
                ),
              ),
            ),
            Semantics(
              label: l.homeAboutSemantics,
              button: true,
              excludeSemantics: true,
              child: IconButton(
                onPressed: () {
                  locator<TtsService>().speak(l.homeOpeningAbout);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
                icon: const Icon(Icons.info_outline, color: Colors.cyanAccent),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: Colors.cyanAccent, height: 2.0),
          ),
        ),
        body: Column(
          children: [

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _MenuCard(
                    title: l.homeMenuLesson,
                    subtitle: l.homeMenuLessonDesc,
                    icon: Icons.school,
                    color: Colors.cyanAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => locator<LessonCubit>(),
                            child: const LessonListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: l.homeMenuCulture,
                    subtitle: l.homeMenuCultureDesc,
                    icon: Icons.public,
                    color: Colors.lightGreenAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => locator<CultureCubit>(),
                            child: const CultureScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: l.homeMenuPodcast,
                    subtitle: l.homeMenuPodcastDesc,
                    icon: Icons.podcasts,
                    color: Colors.deepPurpleAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => locator<PodcastCubit>(),
                            child: const PodcastScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: l.homeMenuRadio,
                    subtitle: l.homeMenuRadioDesc,
                    icon: Icons.radio,
                    color: Colors.amberAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => locator<RadioCubit>(),
                            child: const RadioScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () async {
          // Look up localized string for "Opening {section}"
          final l = AppLocalizations.of(context)!;

          // Play the opening section announcement in the correct language.
          // By awaiting it, we ensure it finishes reading before the next screen loads,
          // preventing TTS overlap bugs.
          await locator<TtsService>().speak(l.homeOpeningSection(title));

          onTap();
        },
        child: Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: color, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(icon, size: 56, color: color),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 36,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
