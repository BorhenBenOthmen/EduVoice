import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'injection_container.dart';
import 'core/auth/token_manager.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';

// Aliasing GetIt to match your locator syntax
final locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupDependencies(); 
  
  // Check session state before launching the UI
  final tokenManager = locator<TokenManager>();
  final hasSession = await tokenManager.hasValidSession();

  runApp(EduVoiceApp(hasSession: hasSession));
}

class EduVoiceApp extends StatelessWidget {
  final bool hasSession;

  const EduVoiceApp({Key? key, required this.hasSession}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVoice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // High Contrast Theme Standard
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // Authenticated users always start at HomeScreen.
      // HomeScreen handles navigation to LessonListScreen when a course is tapped.
      home: hasSession
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}