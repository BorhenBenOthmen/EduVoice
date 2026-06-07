// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:edu_voice/main.dart';
import 'package:edu_voice/injection_container.dart';
import 'package:edu_voice/core/locale/locale_service.dart';
import 'package:edu_voice/core/audio/tts_service.dart';
import 'package:edu_voice/features/notification/presentation/state/notification_cubit.dart';
import 'package:edu_voice/features/notification/presentation/state/notification_state.dart';
import 'package:edu_voice/features/voice_commander/data/gemini_routing_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Manual Fake for FlutterSecureStorage to avoid native channel calls
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #read) {
      final key = invocation.namedArguments[#key] as String;
      return Future.value(_data[key]);
    }
    if (invocation.memberName == #write) {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String?;
      if (value == null) {
        _data.remove(key);
      } else {
        _data[key] = value;
      }
      return Future.value();
    }
    return null;
  }
}

// Manual Fake for TtsService
class FakeTtsService implements TtsService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #speak || 
        invocation.memberName == #stop || 
        invocation.memberName == #speakNotification) {
      return Future.value();
    }
    return null;
  }
}

// Manual Fake for NotificationCubit
class FakeNotificationCubit extends Cubit<NotificationState> implements NotificationCubit {
  FakeNotificationCubit() : super(NotificationInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Manual Fake for GeminiRoutingService
class FakeGeminiRoutingService implements GeminiRoutingService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #isConnected) {
      return false;
    }
    return null;
  }
}

void main() {
  setUpAll(() async {
    final fakeStorage = FakeSecureStorage();
    final localeService = LocaleService(fakeStorage);
    await localeService.init();
    
    locator.registerSingleton<LocaleService>(localeService);
    locator.registerSingleton<TtsService>(FakeTtsService());
    locator.registerSingleton<NotificationCubit>(FakeNotificationCubit());
    locator.registerSingleton<GeminiRoutingService>(FakeGeminiRoutingService());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EduVoiceApp(hasSession: false));
    // Drains the SplashScreen transition timer
    await tester.pump(const Duration(seconds: 5));
  });
}
