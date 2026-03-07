// lib/presentation/screens/lesson_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lesson.dart';
import '../../../../features/lesson/presentation/state/lesson_cubit.dart';
import '../../../../features/lesson/presentation/state/lesson_state.dart';
import '../../../../features/lesson_player/presentation/smart_lesson_player.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.black, // Strict Accessibility: High Contrast
      appBar: AppBar(
        backgroundColor: Colors.black,
        // ARCHITECTURAL FIX 1: Removed 'const' from Semantics, applied to Text only.
        title: Semantics(
          header: true,
          child: const Text(
            "الدروس", // "Lessons"
            style: TextStyle(color: Colors.yellow, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.yellow),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(),
          Expanded(
            child: BlocBuilder<LessonCubit, LessonState>(
              builder: (context, state) {
                if (state is LessonLoading || state is LessonInitial) {
                  // ARCHITECTURAL FIX 2: Removed 'const' from Center and Semantics.
                  return Center(
                    child: Semantics(
                      label: "جاري التحميل", // "Loading"
                      child: const CircularProgressIndicator(color: Colors.yellow),
                    ),
                  );
                } else if (state is LessonError) {
                  return Center(
                    child: Text(
                      "خطأ: ${state.message}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                } else if (state is LessonLoaded) {
                  return _buildLessonList(state.lessons);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Semantics(
        label: "حقل بحث عن درس", // "Search field for a lesson"
        hint: "أدخل اسم الدرس للبحث", // "Enter lesson name to search"
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
            hintText: "بحث...",
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

  Widget _buildLessonList(List<Lesson> allLessons) {
    // Local filtering logic based on the search query
    final filteredLessons = allLessons.where((lesson) {
      return lesson.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredLessons.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد دروس مطابقة", // "No matching lessons"
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        final lesson = filteredLessons[index];
        return _buildLessonTile(lesson);
      },
    );
  }

  Widget _buildLessonTile(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        label: "درس: ${lesson.name}. الوصف: ${lesson.description}",
        hint: "انقر مرتين لفتح الدرس والاستماع إليه", // "Double tap to open and listen"
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.description,
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