// lib/presentation/screens/lesson_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lesson.dart';
import '../../../../features/lesson/presentation/state/lesson_cubit.dart';
import '../../../../features/lesson/presentation/state/lesson_state.dart';
import '../../../../features/lesson_player/presentation/smart_lesson_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../injection_container.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Dispatch the fetch event immediately upon screen load
    context.read<LessonCubit>().loadLessons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black, // Strict Accessibility: High Contrast
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Semantics(
          header: true,
          child: Text(
            l.lessonTitle,
            style: const TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.yellow),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(l),
          Expanded(
            child: BlocConsumer<LessonCubit, LessonState>(
              listener: (context, state) async {
                final tts = locator<TtsService>();
                if (state is LessonLoading) {
                  await tts.speak(l.lessonLoading);
                } else if (state is LessonLoaded) {
                  await tts.speak(l.lessonCountTts(state.lessons.length));
                } else if (state is LessonError) {
                  await tts.speak(l.lessonErrorTts);
                }
              },
              builder: (context, state) {
                if (state is LessonLoading || state is LessonInitial) {
                  return Center(
                    child: Semantics(
                      label: l.lessonLoading,
                      child: const CircularProgressIndicator(color: Colors.yellow),
                    ),
                  );
                } else if (state is LessonError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}", // Keep simple error, typically not narrated unless critical
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                } else if (state is LessonLoaded) {
                  return _buildLessonList(state.lessons, l);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleSearchBar(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Semantics(
        label: l.lessonSearchLabel,
        hint: l.lessonSearchHint,
        textField: true,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black, fontSize: 22),
          textInputAction: TextInputAction.search, // Optimized for TalkBack keyboards
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.yellow,
            hintText: l.lessonSearchPlaceholder,
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Colors.black, size: 32),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonList(List<Lesson> allLessons, AppLocalizations l) {
    // Local filtering logic based on the search query
    final filteredLessons = allLessons.where((lesson) {
      return lesson.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredLessons.isEmpty) {
      return Center(
        child: Text(
          l.lessonEmpty,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        final lesson = filteredLessons[index];
        return _buildLessonTile(lesson, l);
      },
    );
  }

  Widget _buildLessonTile(Lesson lesson, AppLocalizations l) {
    final isArabicName = RegExp(r'[\u0600-\u06FF]').hasMatch(lesson.name);
    final isArabicDesc = RegExp(r'[\u0600-\u06FF]').hasMatch(lesson.description);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonPlayerScreen(lesson: lesson),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow, // High contrast touch target
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0), // Massive padding for easy tapping
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.name,
                  locale: isArabicName ? const Locale('ar') : null,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.description,
                  locale: isArabicDesc ? const Locale('ar') : null,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}