import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/course/domain/course.dart';
import '../../../features/course/data/course_repository.dart';
import '../../../core/audio/tts_service.dart';
import '../../../core/audio/stt_service.dart';
import '../../../core/audio/audio_session_manager.dart';
import '../../../core/audio/audio_feedback_service.dart';
import '../../../injection_container.dart';
import '../../../features/lesson/presentation/state/lesson_cubit.dart';
import '../../../features/lesson/presentation/screens/lesson_list_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;
  bool _isListening = false;
  String _voiceCommandFeedback = "Utilisez le bouton micro pour parler.";

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final repo = locator<CourseRepository>();
    final fetchedCourses = await repo.fetchAvailableCourses();
    
    setState(() {
      _courses = fetchedCourses;
      _isLoading = false;
    });

    await locator<TtsService>().speak(
      "Bienvenue. ${_courses.length} cours sont disponibles. Balayez l'écran pour les parcourir, ou utilisez le bouton micro en bas pour demander de l'aide."
    );
  }

  Future<void> _handleVoiceInteraction() async {
    final stt = locator<SttService>();
    final audio = locator<AudioSessionManager>();
    final tts = locator<TtsService>();
    final earcons = locator<AudioFeedbackService>();

    if (_isListening) {
      // 1. Stop listening
      await stt.stopListening();
      setState(() => _isListening = false);
      
      // 2. Play Earcon to indicate we are processing (Waiting for LLM)
      await earcons.playProcessingChime();
      
      // 3. TTS Feedback
      await tts.speak("Recherche en cours"); 
      await audio.releaseFocus();
      
    } else {
      // 1. Start listening
      setState(() => _isListening = true);
      await audio.requestExclusiveFocus();
      await tts.speak("Je vous écoute");
      
      await stt.startListening((text) {
        setState(() => _voiceCommandFeedback = text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue EduVoice'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // The new About App icon
          Semantics(
            label: "À propos de l'application EduVoice",
            button: true,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.cyanAccent),
              onPressed: () {
                // TODO: Navigate to About Screen
                locator<TtsService>().speak("Ouverture de la page à propos.");
              },
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.cyanAccent, height: 2.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _voiceCommandFeedback,
                    style: const TextStyle(fontSize: 18, color: Colors.amberAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return Semantics(
                        // Explicitly declare this as an interactive list item
                        label: "Cours : ${course.title}. ${course.description}. Appuyez deux fois pour ouvrir. Aucun téléchargement disponible.",
                        child: InkWell(
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
                          child: Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.cyanAccent, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              course.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                course.description,
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ),
                            leading: const Icon(Icons.book, color: Colors.amberAccent, size: 40),
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      // The massive, accessible FAB replacing the invisible gesture
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Semantics(
        label: _isListening 
            ? "Enregistrement en cours. Appuyez deux fois pour arrêter." 
            : "Assistant vocal. Appuyez deux fois pour poser une question.",
        button: true,
        child: FloatingActionButton.large(
          backgroundColor: _isListening ? Colors.redAccent : Colors.cyanAccent,
          onPressed: _handleVoiceInteraction,
          child: Icon(
            _isListening ? Icons.stop : Icons.mic,
            color: Colors.black,
            size: 40,
          ),
        ),
      ),
    );
  }
}