// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'EduVoice';

  @override
  String get welcomeMessage =>
      'Bienvenue sur EduVoice. Plateforme d\'apprentissage pour tous.';

  @override
  String get loginTitle => 'Connexion EduVoice';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginLoading => 'Connexion en cours, veuillez patienter.';

  @override
  String get loginSuccess => 'Connexion réussie. Bienvenue sur EduVoice.';

  @override
  String get loginError =>
      'Échec de la connexion. L\'e-mail ou le mot de passe est incorrect. Veuillez réessayer.';

  @override
  String get loginEmptyFields =>
      'Erreur. L\'e-mail et le mot de passe sont obligatoires.';

  @override
  String get loginEmailSemantics => 'Champ de saisie pour l\'adresse e-mail';

  @override
  String get loginPasswordSemantics => 'Champ de saisie pour le mot de passe';

  @override
  String get loginButtonSemantics =>
      'Bouton de connexion. Appuyez deux fois pour valider.';

  @override
  String get homeCatalogueTitle => 'EduVoice';

  @override
  String get homeWelcomeTts =>
      'Bienvenue sur EduVoice. Choisissez une section : Leçons, Culture, Podcast ou Radio.';

  @override
  String get homeMenuLesson => 'Leçons';

  @override
  String get homeMenuLessonDesc => 'Cours audio interactifs';

  @override
  String get homeMenuCulture => 'Culture';

  @override
  String get homeMenuCultureDesc => 'Découvertes culturelles';

  @override
  String get homeMenuPodcast => 'Podcast';

  @override
  String get homeMenuPodcastDesc => 'Épisodes sélectionnés';

  @override
  String get homeMenuRadio => 'Radio';

  @override
  String get homeMenuRadioDesc => 'Flux en direct';

  @override
  String get homeMenuLessonSemantics =>
      'Section Leçons. Appuyez deux fois pour ouvrir.';

  @override
  String get homeMenuCultureSemantics =>
      'Section Culture. Appuyez deux fois pour ouvrir.';

  @override
  String get homeMenuPodcastSemantics =>
      'Section Podcast. Appuyez deux fois pour ouvrir.';

  @override
  String get homeMenuRadioSemantics =>
      'Section Radio. Appuyez deux fois pour ouvrir.';

  @override
  String get homeListening => 'Je vous écoute';

  @override
  String homeCourseSemantics(String title, String description) {
    return 'Cours : $title. $description. Appuyez deux fois pour ouvrir.';
  }

  @override
  String get homeAboutSemantics => 'À propos de l\'application';

  @override
  String get homeSettingsSemantics => 'Paramètres de l\'application';

  @override
  String get homeOpeningAbout => 'Ouverture de la page à propos.';

  @override
  String get homeOpeningSettings => 'Ouverture des paramètres.';

  @override
  String homeOpeningSection(String title) {
    return 'Ouverture de la section : $title.';
  }

  @override
  String get lessonTitle => 'Leçons';

  @override
  String get lessonSearchLabel => 'Rechercher une leçon';

  @override
  String get lessonSearchHint => 'Saisir le nom de la leçon';

  @override
  String get lessonSearchPlaceholder => 'Recherche...';

  @override
  String get lessonEmpty => 'Aucune leçon trouvée.';

  @override
  String get lessonLoading => 'Chargement des leçons';

  @override
  String lessonCountTts(int count) {
    return '$count leçons trouvées.';
  }

  @override
  String get lessonErrorTts =>
      'Une erreur est survenue lors du chargement des leçons. Veuillez réessayer.';

  @override
  String lessonTileSemantics(String name, String description) {
    return 'Leçon : $name. $description. Appuyez deux fois pour écouter.';
  }

  @override
  String lessonPlayerOpening(String name) {
    return 'Ouverture de la leçon : $name.';
  }

  @override
  String lessonPlayerDescription(String desc) {
    return 'Description de la leçon : $desc';
  }

  @override
  String get lessonPlayerTranscript => 'Transcription';

  @override
  String get lessonPlayerNoAudio =>
      'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.';

  @override
  String get lessonPlayerPlay => 'Lecture';

  @override
  String get lessonPlayerPause => 'Pause';

  @override
  String get lessonPlayerStop => 'Arrêter et revenir au début';

  @override
  String get lessonPlayerReplay => 'Reculer de 10 secondes';

  @override
  String get lessonPlayerFastForward => 'Avancer de 10 secondes';

  @override
  String get lessonPlayerRewind => 'Reculer de 10 secondes';

  @override
  String get lessonPlayerSpeedIncrease => 'Augmenter la vitesse de lecture';

  @override
  String get lessonPlayerSpeedDecrease => 'Diminuer la vitesse de lecture';

  @override
  String lessonPlayerCurrentSpeed(String speed) {
    return 'Vitesse ${speed}x';
  }

  @override
  String get lessonPlayerListen => 'Écouter la leçon';

  @override
  String get lessonPlayerStopTts => 'Arrêter l\'écoute';

  @override
  String get lessonPlayerStopLabel =>
      'Arrêter l\'écoute. Appuyez deux fois pour arrêter.';

  @override
  String get lessonPlayerListenLabel =>
      'Commencer l\'écoute de la leçon. Appuyez deux fois pour lancer.';

  @override
  String get podcastTitle => 'Podcast';

  @override
  String get podcastSearchLabel => 'Rechercher un podcast';

  @override
  String get podcastSearchHint => 'Saisir le nom du podcast';

  @override
  String get podcastSearchPlaceholder => 'Recherche...';

  @override
  String get podcastEmpty => 'Aucun podcast trouvé.';

  @override
  String get podcastLoading => 'Chargement des podcasts';

  @override
  String podcastCountTts(int count) {
    return '$count podcasts trouvés.';
  }

  @override
  String get podcastErrorTts =>
      'Une erreur est survenue lors du chargement des podcasts. Veuillez réessayer.';

  @override
  String podcastTileSemantics(String name, String description) {
    return 'Podcast : $name. $description. Appuyez deux fois pour écouter.';
  }

  @override
  String podcastPlayerOpening(String name) {
    return 'Ouverture du podcast : $name.';
  }

  @override
  String podcastPlayerDescription(String desc) {
    return 'Description du podcast : $desc';
  }

  @override
  String get podcastPlayerTranscript => 'Transcription';

  @override
  String get podcastPlayerNoAudio =>
      'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.';

  @override
  String get podcastPlayerListen => 'Écouter le podcast';

  @override
  String get podcastTts =>
      'Section Podcast. Bientôt disponible — des épisodes sélectionnés pour enrichir votre apprentissage.';

  @override
  String get podcastComingSoon => 'Bientôt disponible';

  @override
  String get podcastComingSoonDesc =>
      'Des podcasts enrichissants seront proposés très prochainement.';

  @override
  String get radioTitle => 'Radio';

  @override
  String get radioTts =>
      'Section Radio. Bientôt disponible — flux éducatifs en direct.';

  @override
  String get radioComingSoon => 'Bientôt disponible';

  @override
  String get radioComingSoonDesc =>
      'Des flux radio éducatifs en direct seront disponibles très prochainement.';

  @override
  String get cultureTitle => 'Culture';

  @override
  String get cultureSearchLabel => 'Rechercher un enregistrement culturel';

  @override
  String get cultureSearchHint => 'Entrez le nom de l\'enregistrement';

  @override
  String get cultureSearchPlaceholder => 'Recherche...';

  @override
  String get cultureEmpty => 'Aucun enregistrement culturel trouvé.';

  @override
  String get cultureLoading => 'Chargement des enregistrements culturels';

  @override
  String cultureCountTts(int count) {
    return '$count enregistrements culturels trouvés.';
  }

  @override
  String get cultureErrorTts =>
      'Une erreur s\'est produite lors du chargement des enregistrements culturels. Veuillez réessayer.';

  @override
  String cultureTileSemantics(String name, String description) {
    return 'Enregistrement Culturel : $name. $description. Touchez deux fois pour écouter.';
  }

  @override
  String culturePlayerOpening(String name) {
    return 'Ouverture de l\'enregistrement culturel : $name.';
  }

  @override
  String culturePlayerDescription(String desc) {
    return 'Description de l\'enregistrement : $desc';
  }

  @override
  String get culturePlayerTranscript => 'Transcription';

  @override
  String get culturePlayerNoAudio =>
      'Aucun fichier audio disponible. Vous pouvez écouter la description lue à haute voix.';

  @override
  String get culturePlayerListen => 'Écouter l\'enregistrement';

  @override
  String get cultureTts =>
      'Section Culture. Bientôt disponible — explorez le monde à travers des histoires culturelles.';

  @override
  String get cultureComingSoon => 'Bientôt disponible';

  @override
  String get cultureComingSoonDesc =>
      'Des contenus culturels enrichissants seront proposés très prochainement.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsTts => 'Ouverture des paramètres de l\'application.';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageArSemantics => 'Arabe';

  @override
  String get settingsLanguageFrSemantics => 'Français';

  @override
  String get settingsLanguageEnSemantics => 'Anglais';

  @override
  String get settingsLanguageSelected => 'sélectionné';

  @override
  String settingsLanguageChanged(String lang) {
    return 'Langue changée en $lang.';
  }

  @override
  String get settingsTtsSection => 'Voix et audio';

  @override
  String get settingsTtsSpeed => 'Vitesse de lecture';

  @override
  String get settingsTtsSpeedSlow => 'Lente';

  @override
  String get settingsTtsSpeedNormal => 'Normale';

  @override
  String get settingsTtsSpeedFast => 'Rapide';

  @override
  String settingsTtsSpeedChanged(String speed) {
    return 'Vitesse de lecture changée en $speed.';
  }

  @override
  String get settingsTtsVolume => 'Volume de la voix';

  @override
  String settingsTtsVolumeChanged(int percent) {
    return 'Volume réglé à $percent pourcent.';
  }

  @override
  String get settingsTtsTest => 'C\'est ainsi que je lis le contenu pour vous.';

  @override
  String get settingsAboutButton => 'À propos de l\'application';

  @override
  String get settingsAboutSemantics => 'Aller à la page À propos';

  @override
  String get aboutTitle => 'À propos de EduVoice';

  @override
  String get aboutTts =>
      'Page à propos. EduVoice est une plateforme d\'apprentissage accessible pour les personnes malvoyantes. Version un point zéro. Notre mission est d\'autonomiser tous les apprenants grâce à une éducation axée sur la voix.';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutVersion => '1.0.0';

  @override
  String get aboutMissionTitle => 'Notre Mission';

  @override
  String get aboutMissionBody =>
      'Autonomiser les apprenants malvoyants grâce à une éducation axée sur la voix.';

  @override
  String get aboutFeaturesTitle => 'Fonctionnalités';

  @override
  String get aboutFeature1 => 'Leçons audio interactives';

  @override
  String get aboutFeature2 => 'Radio éducative en direct';

  @override
  String get aboutFeature3 => 'Podcasts sélectionnés';

  @override
  String get aboutFeature4 => 'Explorateur culturel';

  @override
  String get aboutFeature5 => 'Commandes vocales';

  @override
  String get aboutA11yTitle => 'Accessibilité';

  @override
  String get aboutA11yBody =>
      'EduVoice est conçu selon les critères WCAG 2.1 AA et les meilleures pratiques d\'accessibilité pour les lecteurs d\'écran. Chaque écran est entièrement navigable à la voix et au toucher.';

  @override
  String get aboutTeamTitle => 'Équipe';

  @override
  String get aboutTeamBody =>
      'Développé par l\'équipe PFE — Projet de Fin d\'Études en ingénierie logicielle.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactBody => 'contact@eduvoice.app';

  @override
  String get radioSearchLabel => 'Rechercher un flux radio';

  @override
  String get radioSearchHint => 'Saisir le nom du flux';

  @override
  String get radioSearchPlaceholder => 'Recherche...';

  @override
  String get radioEmpty => 'Aucun flux radio trouvé.';

  @override
  String get radioLoading => 'Chargement des flux radio';

  @override
  String radioCountTts(int count) {
    return '$count flux radio trouvés.';
  }

  @override
  String get radioErrorTts =>
      'Une erreur est survenue lors du chargement des flux radio. Veuillez réessayer.';

  @override
  String radioTileSemantics(String name, String description) {
    return 'Flux Radio : $name. $description. Appuyez deux fois pour écouter.';
  }

  @override
  String radioPlayerOpening(String name) {
    return 'Ouverture du flux radio : $name.';
  }

  @override
  String radioPlayerDescription(String desc) {
    return 'Description du flux : $desc';
  }

  @override
  String get radioPlayerTranscript => 'Transcription';

  @override
  String get radioPlayerNoAudio =>
      'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.';

  @override
  String get radioPlayerListen => 'Écouter le flux';

  @override
  String get voiceErrorTts =>
      'Une erreur de connexion s\'est produite. Veuillez réessayer.';

  @override
  String get voiceGoodbyeTts => 'Session terminée.';

  @override
  String get notificationArrived => 'Une nouvelle notification est survenue.';

  @override
  String get homeNotificationSemantics => 'Ouvrir les notifications';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationEmpty => 'Aucune notification pour le moment.';

  @override
  String get notificationDeleteSemantics => 'Supprimer la notification';

  @override
  String get notificationOpening => 'Ouverture des notifications';
}
