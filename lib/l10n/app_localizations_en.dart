// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EduVoice';

  @override
  String get welcomeMessage =>
      'Welcome to EduVoice. The learning platform for everyone.';

  @override
  String get loginTitle => 'EduVoice Login';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginLoading => 'Signing in, please wait.';

  @override
  String get loginSuccess => 'Login successful. Welcome to EduVoice.';

  @override
  String get loginError =>
      'Login failed. The e-mail or password is incorrect. Please try again.';

  @override
  String get loginEmptyFields => 'Error. E-mail and password are required.';

  @override
  String get loginEmailSemantics => 'E-mail input field';

  @override
  String get loginPasswordSemantics => 'Password input field';

  @override
  String get loginButtonSemantics => 'Log in button. Double-tap to confirm.';

  @override
  String get homeCatalogueTitle => 'EduVoice';

  @override
  String get homeWelcomeTts =>
      'Welcome to EduVoice. Choose a section: Lessons, Culture, Podcast, or Radio.';

  @override
  String get homeMenuLesson => 'Lessons';

  @override
  String get homeMenuLessonDesc => 'Interactive audio courses';

  @override
  String get homeMenuCulture => 'Culture';

  @override
  String get homeMenuCultureDesc => 'Cultural discoveries';

  @override
  String get homeMenuPodcast => 'Podcast';

  @override
  String get homeMenuPodcastDesc => 'Curated episodes';

  @override
  String get homeMenuRadio => 'Radio';

  @override
  String get homeMenuRadioDesc => 'Live streams';

  @override
  String get homeMenuLessonSemantics => 'Lessons section. Double-tap to open.';

  @override
  String get homeMenuCultureSemantics => 'Culture section. Double-tap to open.';

  @override
  String get homeMenuPodcastSemantics => 'Podcast section. Double-tap to open.';

  @override
  String get homeMenuRadioSemantics => 'Radio section. Double-tap to open.';

  @override
  String get homeListeningButton =>
      'Recording in progress. Double-tap to stop.';

  @override
  String get homeMicButton => 'Voice assistant. Double-tap to ask a question.';

  @override
  String get homeVoiceDefault => 'Use the mic button to speak.';

  @override
  String get homeSearching => 'Searching';

  @override
  String get homeListening => 'I am listening';

  @override
  String homeCourseSemantics(String title, String description) {
    return 'Course: $title. $description. Double-tap to open.';
  }

  @override
  String get homeAboutSemantics => 'About the application';

  @override
  String get homeSettingsSemantics => 'Application settings';

  @override
  String get homeOpeningAbout => 'Opening the about page.';

  @override
  String get homeOpeningSettings => 'Opening settings.';

  @override
  String homeOpeningSection(String title) {
    return 'Opening $title.';
  }

  @override
  String get lessonTitle => 'Lessons';

  @override
  String get lessonSearchLabel => 'Search for a lesson';

  @override
  String get lessonSearchHint => 'Enter the lesson name';

  @override
  String get lessonSearchPlaceholder => 'Search...';

  @override
  String get lessonEmpty => 'No lessons found.';

  @override
  String get lessonLoading => 'Loading lessons';

  @override
  String lessonCountTts(int count) {
    return 'Found $count lessons.';
  }

  @override
  String get lessonErrorTts =>
      'An error occurred while loading lessons. Please try again.';

  @override
  String lessonTileSemantics(String name, String description) {
    return 'Lesson: $name. $description. Double-tap to listen.';
  }

  @override
  String lessonPlayerOpening(String name) {
    return 'Opening lesson: $name.';
  }

  @override
  String lessonPlayerDescription(String desc) {
    return 'Lesson description: $desc';
  }

  @override
  String get lessonPlayerTranscript => 'Transcript';

  @override
  String get lessonPlayerNoAudio =>
      'No audio file available. You can listen to the description read aloud.';

  @override
  String get lessonPlayerPlay => 'Play';

  @override
  String get lessonPlayerPause => 'Pause';

  @override
  String get lessonPlayerStop => 'Stop and return to beginning';

  @override
  String get lessonPlayerReplay => 'Rewind 10 seconds';

  @override
  String get lessonPlayerFastForward => 'Fast forward 10 seconds';

  @override
  String get lessonPlayerRewind => 'Rewind 10 seconds';

  @override
  String get lessonPlayerSpeedIncrease => 'Increase playback speed';

  @override
  String get lessonPlayerSpeedDecrease => 'Decrease playback speed';

  @override
  String lessonPlayerCurrentSpeed(String speed) {
    return 'Speed ${speed}x';
  }

  @override
  String get lessonPlayerListen => 'Listen to lesson';

  @override
  String get lessonPlayerStopTts => 'Stop listening';

  @override
  String get lessonPlayerStopLabel => 'Stop listening. Double-tap to stop.';

  @override
  String get lessonPlayerListenLabel =>
      'Start listening to the lesson aloud. Double-tap to play.';

  @override
  String get podcastTitle => 'Podcast';

  @override
  String get podcastSearchLabel => 'Search for a podcast';

  @override
  String get podcastSearchHint => 'Enter the podcast name';

  @override
  String get podcastSearchPlaceholder => 'Search...';

  @override
  String get podcastEmpty => 'No podcasts found.';

  @override
  String get podcastLoading => 'Loading podcasts';

  @override
  String podcastCountTts(int count) {
    return 'Found $count podcasts.';
  }

  @override
  String get podcastErrorTts =>
      'An error occurred while loading podcasts. Please try again.';

  @override
  String podcastTileSemantics(String name, String description) {
    return 'Podcast: $name. $description. Double-tap to listen.';
  }

  @override
  String podcastPlayerOpening(String name) {
    return 'Opening podcast: $name.';
  }

  @override
  String podcastPlayerDescription(String desc) {
    return 'Podcast description: $desc';
  }

  @override
  String get podcastPlayerTranscript => 'Transcript';

  @override
  String get podcastPlayerNoAudio =>
      'No audio file available. You can listen to the description read aloud.';

  @override
  String get podcastPlayerListen => 'Listen to podcast';

  @override
  String get podcastTts =>
      'Podcast section. Coming soon — curated episodes to enrich your learning.';

  @override
  String get podcastComingSoon => 'Coming Soon';

  @override
  String get podcastComingSoonDesc =>
      'Enriching podcasts will be available very soon.';

  @override
  String get radioTitle => 'Radio';

  @override
  String get radioTts =>
      'Radio section. Coming soon — live educational streams.';

  @override
  String get radioComingSoon => 'Coming Soon';

  @override
  String get radioComingSoonDesc =>
      'Live educational radio streams will be available very soon.';

  @override
  String get cultureTitle => 'Culture';

  @override
  String get cultureSearchLabel => 'Search for a culture record';

  @override
  String get cultureSearchHint => 'Enter the record name';

  @override
  String get cultureSearchPlaceholder => 'Search...';

  @override
  String get cultureEmpty => 'No culture records found.';

  @override
  String get cultureLoading => 'Loading culture records';

  @override
  String cultureCountTts(int count) {
    return 'Found $count culture records.';
  }

  @override
  String get cultureErrorTts =>
      'An error occurred while loading culture records. Please try again.';

  @override
  String cultureTileSemantics(String name, String description) {
    return 'Culture Record: $name. $description. Double-tap to listen.';
  }

  @override
  String culturePlayerOpening(String name) {
    return 'Opening culture record: $name.';
  }

  @override
  String culturePlayerDescription(String desc) {
    return 'Record description: $desc';
  }

  @override
  String get culturePlayerTranscript => 'Transcript';

  @override
  String get culturePlayerNoAudio =>
      'No audio file available. You can listen to the description read aloud.';

  @override
  String get culturePlayerListen => 'Listen to record';

  @override
  String get cultureTts =>
      'Culture section. Coming soon — explore the world through cultural stories.';

  @override
  String get cultureComingSoon => 'Coming Soon';

  @override
  String get cultureComingSoonDesc =>
      'Enriching cultural content will be available very soon.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTts => 'Opening application settings.';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageArSemantics => 'Arabic';

  @override
  String get settingsLanguageFrSemantics => 'French';

  @override
  String get settingsLanguageEnSemantics => 'English';

  @override
  String get settingsLanguageSelected => 'selected';

  @override
  String settingsLanguageChanged(String lang) {
    return 'Language changed to $lang.';
  }

  @override
  String get settingsTtsSection => 'Voice & Audio';

  @override
  String get settingsTtsSpeed => 'Reading speed';

  @override
  String get settingsTtsSpeedSlow => 'Slow';

  @override
  String get settingsTtsSpeedNormal => 'Normal';

  @override
  String get settingsTtsSpeedFast => 'Fast';

  @override
  String settingsTtsSpeedChanged(String speed) {
    return 'Reading speed changed to $speed.';
  }

  @override
  String get settingsTtsVolume => 'Voice volume';

  @override
  String settingsTtsVolumeChanged(int percent) {
    return 'Volume set to $percent percent.';
  }

  @override
  String get settingsTtsTest => 'This is how I read content for you.';

  @override
  String get settingsAboutButton => 'About the application';

  @override
  String get settingsAboutSemantics => 'Go to the About page';

  @override
  String get aboutTitle => 'About EduVoice';

  @override
  String get aboutTts =>
      'About page. EduVoice is an accessible learning platform for visually impaired users. Version one point zero. Our mission is to empower all learners through voice-first education.';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutVersion => '1.0.0';

  @override
  String get aboutMissionTitle => 'Our Mission';

  @override
  String get aboutMissionBody =>
      'Empowering visually impaired learners through voice-first education.';

  @override
  String get aboutFeaturesTitle => 'Features';

  @override
  String get aboutFeature1 => 'Interactive audio lessons';

  @override
  String get aboutFeature2 => 'Live educational radio';

  @override
  String get aboutFeature3 => 'Curated podcasts';

  @override
  String get aboutFeature4 => 'Cultural explorer';

  @override
  String get aboutFeature5 => 'Voice commands';

  @override
  String get aboutA11yTitle => 'Accessibility';

  @override
  String get aboutA11yBody =>
      'EduVoice is designed to WCAG 2.1 AA standards and screen-reader best practices. Every screen is fully navigable by voice and touch.';

  @override
  String get aboutTeamTitle => 'Team';

  @override
  String get aboutTeamBody =>
      'Developed by the PFE Team — Final Year Software Engineering Project.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactBody => 'contact@eduvoice.app';

  @override
  String get radioSearchLabel => 'Search for a radio stream';

  @override
  String get radioSearchHint => 'Enter the stream name';

  @override
  String get radioSearchPlaceholder => 'Search...';

  @override
  String get radioEmpty => 'No radio streams found.';

  @override
  String get radioLoading => 'Loading radio streams';

  @override
  String radioCountTts(int count) {
    return 'Found $count radio streams.';
  }

  @override
  String get radioErrorTts =>
      'An error occurred while loading radio streams. Please try again.';

  @override
  String radioTileSemantics(String name, String description) {
    return 'Radio Stream: $name. $description. Double-tap to listen.';
  }

  @override
  String radioPlayerOpening(String name) {
    return 'Opening radio stream: $name.';
  }

  @override
  String radioPlayerDescription(String desc) {
    return 'Stream description: $desc';
  }

  @override
  String get radioPlayerTranscript => 'Transcript';

  @override
  String get radioPlayerNoAudio =>
      'No audio stream available. You can listen to the description read aloud.';

  @override
  String get radioPlayerListen => 'Listen to stream';
}
