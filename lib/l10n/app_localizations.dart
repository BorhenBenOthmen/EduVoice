import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
  ];

  /// Application title
  ///
  /// In fr, this message translates to:
  /// **'EduVoice'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur EduVoice. Plateforme d\'apprentissage pour tous.'**
  String get welcomeMessage;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion EduVoice'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours, veuillez patienter.'**
  String get loginLoading;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie. Bienvenue sur EduVoice.'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion. L\'e-mail ou le mot de passe est incorrect. Veuillez réessayer.'**
  String get loginError;

  /// No description provided for @loginEmptyFields.
  ///
  /// In fr, this message translates to:
  /// **'Erreur. L\'e-mail et le mot de passe sont obligatoires.'**
  String get loginEmptyFields;

  /// No description provided for @loginEmailSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ de saisie pour l\'adresse e-mail'**
  String get loginEmailSemantics;

  /// No description provided for @loginPasswordSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ de saisie pour le mot de passe'**
  String get loginPasswordSemantics;

  /// No description provided for @loginButtonSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Bouton de connexion. Appuyez deux fois pour valider.'**
  String get loginButtonSemantics;

  /// No description provided for @homeCatalogueTitle.
  ///
  /// In fr, this message translates to:
  /// **'EduVoice'**
  String get homeCatalogueTitle;

  /// No description provided for @homeWelcomeTts.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur EduVoice. Choisissez une section : Leçons, Culture, Podcast ou Radio.'**
  String get homeWelcomeTts;

  /// No description provided for @homeMenuLesson.
  ///
  /// In fr, this message translates to:
  /// **'Leçons'**
  String get homeMenuLesson;

  /// No description provided for @homeMenuLessonDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cours audio interactifs'**
  String get homeMenuLessonDesc;

  /// No description provided for @homeMenuCulture.
  ///
  /// In fr, this message translates to:
  /// **'Culture'**
  String get homeMenuCulture;

  /// No description provided for @homeMenuCultureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Découvertes culturelles'**
  String get homeMenuCultureDesc;

  /// No description provided for @homeMenuPodcast.
  ///
  /// In fr, this message translates to:
  /// **'Podcast'**
  String get homeMenuPodcast;

  /// No description provided for @homeMenuPodcastDesc.
  ///
  /// In fr, this message translates to:
  /// **'Épisodes sélectionnés'**
  String get homeMenuPodcastDesc;

  /// No description provided for @homeMenuRadio.
  ///
  /// In fr, this message translates to:
  /// **'Radio'**
  String get homeMenuRadio;

  /// No description provided for @homeMenuRadioDesc.
  ///
  /// In fr, this message translates to:
  /// **'Flux en direct'**
  String get homeMenuRadioDesc;

  /// No description provided for @homeMenuLessonSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Section Leçons. Appuyez deux fois pour ouvrir.'**
  String get homeMenuLessonSemantics;

  /// No description provided for @homeMenuCultureSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Section Culture. Appuyez deux fois pour ouvrir.'**
  String get homeMenuCultureSemantics;

  /// No description provided for @homeMenuPodcastSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Section Podcast. Appuyez deux fois pour ouvrir.'**
  String get homeMenuPodcastSemantics;

  /// No description provided for @homeMenuRadioSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Section Radio. Appuyez deux fois pour ouvrir.'**
  String get homeMenuRadioSemantics;

  /// No description provided for @homeListening.
  ///
  /// In fr, this message translates to:
  /// **'Je vous écoute'**
  String get homeListening;

  /// No description provided for @homeCourseSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Cours : {title}. {description}. Appuyez deux fois pour ouvrir.'**
  String homeCourseSemantics(String title, String description);

  /// No description provided for @homeAboutSemantics.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'application'**
  String get homeAboutSemantics;

  /// No description provided for @homeSettingsSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'application'**
  String get homeSettingsSemantics;

  /// No description provided for @homeOpeningAbout.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de la page à propos.'**
  String get homeOpeningAbout;

  /// No description provided for @homeOpeningSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture des paramètres.'**
  String get homeOpeningSettings;

  /// No description provided for @homeOpeningSection.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de la section : {title}.'**
  String homeOpeningSection(String title);

  /// No description provided for @lessonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Leçons'**
  String get lessonTitle;

  /// No description provided for @lessonSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une leçon'**
  String get lessonSearchLabel;

  /// No description provided for @lessonSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le nom de la leçon'**
  String get lessonSearchHint;

  /// No description provided for @lessonSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get lessonSearchPlaceholder;

  /// No description provided for @lessonEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune leçon trouvée.'**
  String get lessonEmpty;

  /// No description provided for @lessonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des leçons'**
  String get lessonLoading;

  /// No description provided for @lessonCountTts.
  ///
  /// In fr, this message translates to:
  /// **'{count} leçons trouvées.'**
  String lessonCountTts(int count);

  /// No description provided for @lessonErrorTts.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors du chargement des leçons. Veuillez réessayer.'**
  String get lessonErrorTts;

  /// No description provided for @lessonTileSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Leçon : {name}. {description}. Appuyez deux fois pour écouter.'**
  String lessonTileSemantics(String name, String description);

  /// No description provided for @lessonPlayerOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de la leçon : {name}.'**
  String lessonPlayerOpening(String name);

  /// No description provided for @lessonPlayerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description de la leçon : {desc}'**
  String lessonPlayerDescription(String desc);

  /// No description provided for @lessonPlayerTranscript.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get lessonPlayerTranscript;

  /// No description provided for @lessonPlayerTranscriptHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez deux fois pour afficher la transcription'**
  String get lessonPlayerTranscriptHint;

  /// No description provided for @lessonPlayerTranscriptClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la transcription'**
  String get lessonPlayerTranscriptClose;

  /// No description provided for @lessonPlayerNoAudio.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.'**
  String get lessonPlayerNoAudio;

  /// No description provided for @lessonPlayerPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get lessonPlayerPlay;

  /// No description provided for @lessonPlayerPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get lessonPlayerPause;

  /// No description provided for @lessonPlayerStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter et revenir au début'**
  String get lessonPlayerStop;

  /// No description provided for @lessonPlayerReplay.
  ///
  /// In fr, this message translates to:
  /// **'Reculer de 10 secondes'**
  String get lessonPlayerReplay;

  /// No description provided for @lessonPlayerFastForward.
  ///
  /// In fr, this message translates to:
  /// **'Avancer de 10 secondes'**
  String get lessonPlayerFastForward;

  /// No description provided for @lessonPlayerRewind.
  ///
  /// In fr, this message translates to:
  /// **'Reculer de 10 secondes'**
  String get lessonPlayerRewind;

  /// No description provided for @lessonPlayerSpeedIncrease.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter la vitesse de lecture'**
  String get lessonPlayerSpeedIncrease;

  /// No description provided for @lessonPlayerSpeedDecrease.
  ///
  /// In fr, this message translates to:
  /// **'Diminuer la vitesse de lecture'**
  String get lessonPlayerSpeedDecrease;

  /// No description provided for @lessonPlayerCurrentSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse {speed}x'**
  String lessonPlayerCurrentSpeed(String speed);

  /// No description provided for @lessonPlayerListen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter la leçon'**
  String get lessonPlayerListen;

  /// No description provided for @lessonPlayerStopTts.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter l\'écoute'**
  String get lessonPlayerStopTts;

  /// No description provided for @lessonPlayerStopLabel.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter l\'écoute. Appuyez deux fois pour arrêter.'**
  String get lessonPlayerStopLabel;

  /// No description provided for @lessonPlayerListenLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commencer l\'écoute de la leçon. Appuyez deux fois pour lancer.'**
  String get lessonPlayerListenLabel;

  /// No description provided for @podcastTitle.
  ///
  /// In fr, this message translates to:
  /// **'Podcast'**
  String get podcastTitle;

  /// No description provided for @podcastSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un podcast'**
  String get podcastSearchLabel;

  /// No description provided for @podcastSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le nom du podcast'**
  String get podcastSearchHint;

  /// No description provided for @podcastSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get podcastSearchPlaceholder;

  /// No description provided for @podcastEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun podcast trouvé.'**
  String get podcastEmpty;

  /// No description provided for @podcastLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des podcasts'**
  String get podcastLoading;

  /// No description provided for @podcastCountTts.
  ///
  /// In fr, this message translates to:
  /// **'{count} podcasts trouvés.'**
  String podcastCountTts(int count);

  /// No description provided for @podcastErrorTts.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors du chargement des podcasts. Veuillez réessayer.'**
  String get podcastErrorTts;

  /// No description provided for @podcastTileSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Podcast : {name}. {description}. Appuyez deux fois pour écouter.'**
  String podcastTileSemantics(String name, String description);

  /// No description provided for @podcastPlayerOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture du podcast : {name}.'**
  String podcastPlayerOpening(String name);

  /// No description provided for @podcastPlayerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description du podcast : {desc}'**
  String podcastPlayerDescription(String desc);

  /// No description provided for @podcastPlayerTranscript.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get podcastPlayerTranscript;

  /// No description provided for @podcastPlayerNoAudio.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.'**
  String get podcastPlayerNoAudio;

  /// No description provided for @podcastPlayerListen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter le podcast'**
  String get podcastPlayerListen;

  /// No description provided for @podcastTts.
  ///
  /// In fr, this message translates to:
  /// **'Section Podcast. Bientôt disponible — des épisodes sélectionnés pour enrichir votre apprentissage.'**
  String get podcastTts;

  /// No description provided for @podcastComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get podcastComingSoon;

  /// No description provided for @podcastComingSoonDesc.
  ///
  /// In fr, this message translates to:
  /// **'Des podcasts enrichissants seront proposés très prochainement.'**
  String get podcastComingSoonDesc;

  /// No description provided for @radioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Radio'**
  String get radioTitle;

  /// No description provided for @radioTts.
  ///
  /// In fr, this message translates to:
  /// **'Section Radio. Bientôt disponible — flux éducatifs en direct.'**
  String get radioTts;

  /// No description provided for @radioComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get radioComingSoon;

  /// No description provided for @radioComingSoonDesc.
  ///
  /// In fr, this message translates to:
  /// **'Des flux radio éducatifs en direct seront disponibles très prochainement.'**
  String get radioComingSoonDesc;

  /// No description provided for @cultureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Culture'**
  String get cultureTitle;

  /// No description provided for @cultureSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un enregistrement culturel'**
  String get cultureSearchLabel;

  /// No description provided for @cultureSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le nom de l\'enregistrement'**
  String get cultureSearchHint;

  /// No description provided for @cultureSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get cultureSearchPlaceholder;

  /// No description provided for @cultureEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enregistrement culturel trouvé.'**
  String get cultureEmpty;

  /// No description provided for @cultureLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des enregistrements culturels'**
  String get cultureLoading;

  /// No description provided for @cultureCountTts.
  ///
  /// In fr, this message translates to:
  /// **'{count} enregistrements culturels trouvés.'**
  String cultureCountTts(int count);

  /// No description provided for @cultureErrorTts.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite lors du chargement des enregistrements culturels. Veuillez réessayer.'**
  String get cultureErrorTts;

  /// No description provided for @cultureTileSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement Culturel : {name}. {description}. Touchez deux fois pour écouter.'**
  String cultureTileSemantics(String name, String description);

  /// No description provided for @culturePlayerOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture de l\'enregistrement culturel : {name}.'**
  String culturePlayerOpening(String name);

  /// No description provided for @culturePlayerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description de l\'enregistrement : {desc}'**
  String culturePlayerDescription(String desc);

  /// No description provided for @culturePlayerTranscript.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get culturePlayerTranscript;

  /// No description provided for @culturePlayerNoAudio.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier audio disponible. Vous pouvez écouter la description lue à haute voix.'**
  String get culturePlayerNoAudio;

  /// No description provided for @culturePlayerListen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter l\'enregistrement'**
  String get culturePlayerListen;

  /// No description provided for @cultureTts.
  ///
  /// In fr, this message translates to:
  /// **'Section Culture. Bientôt disponible — explorez le monde à travers des histoires culturelles.'**
  String get cultureTts;

  /// No description provided for @cultureComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get cultureComingSoon;

  /// No description provided for @cultureComingSoonDesc.
  ///
  /// In fr, this message translates to:
  /// **'Des contenus culturels enrichissants seront proposés très prochainement.'**
  String get cultureComingSoonDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsTts.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture des paramètres de l\'application.'**
  String get settingsTts;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageAr.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get settingsLanguageAr;

  /// No description provided for @settingsLanguageFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageArSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get settingsLanguageArSemantics;

  /// No description provided for @settingsLanguageFrSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrSemantics;

  /// No description provided for @settingsLanguageEnSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get settingsLanguageEnSemantics;

  /// No description provided for @settingsLanguageSelected.
  ///
  /// In fr, this message translates to:
  /// **'sélectionné'**
  String get settingsLanguageSelected;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In fr, this message translates to:
  /// **'Langue changée en {lang}.'**
  String settingsLanguageChanged(String lang);

  /// No description provided for @settingsTtsSection.
  ///
  /// In fr, this message translates to:
  /// **'Voix et audio'**
  String get settingsTtsSection;

  /// No description provided for @settingsTtsSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse de lecture'**
  String get settingsTtsSpeed;

  /// No description provided for @settingsTtsSpeedSlow.
  ///
  /// In fr, this message translates to:
  /// **'Lente'**
  String get settingsTtsSpeedSlow;

  /// No description provided for @settingsTtsSpeedNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get settingsTtsSpeedNormal;

  /// No description provided for @settingsTtsSpeedFast.
  ///
  /// In fr, this message translates to:
  /// **'Rapide'**
  String get settingsTtsSpeedFast;

  /// No description provided for @settingsTtsSpeedChanged.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse de lecture changée en {speed}.'**
  String settingsTtsSpeedChanged(String speed);

  /// No description provided for @settingsTtsVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume de la voix'**
  String get settingsTtsVolume;

  /// No description provided for @settingsTtsVolumeChanged.
  ///
  /// In fr, this message translates to:
  /// **'Volume réglé à {percent} pourcent.'**
  String settingsTtsVolumeChanged(int percent);

  /// No description provided for @settingsTtsTest.
  ///
  /// In fr, this message translates to:
  /// **'C\'est ainsi que je lis le contenu pour vous.'**
  String get settingsTtsTest;

  /// No description provided for @settingsAboutButton.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'application'**
  String get settingsAboutButton;

  /// No description provided for @settingsAboutSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la page À propos'**
  String get settingsAboutSemantics;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos de EduVoice'**
  String get aboutTitle;

  /// No description provided for @aboutTts.
  ///
  /// In fr, this message translates to:
  /// **'Page à propos. EduVoice est une plateforme d\'apprentissage accessible pour les personnes malvoyantes. Version un point zéro. Notre mission est d\'autonomiser tous les apprenants grâce à une éducation axée sur la voix.'**
  String get aboutTts;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre Mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In fr, this message translates to:
  /// **'Autonomiser les apprenants malvoyants grâce à une éducation axée sur la voix.'**
  String get aboutMissionBody;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeature1.
  ///
  /// In fr, this message translates to:
  /// **'Leçons audio interactives'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In fr, this message translates to:
  /// **'Radio éducative en direct'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In fr, this message translates to:
  /// **'Podcasts sélectionnés'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur culturel'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In fr, this message translates to:
  /// **'Commandes vocales'**
  String get aboutFeature5;

  /// No description provided for @aboutA11yTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get aboutA11yTitle;

  /// No description provided for @aboutA11yBody.
  ///
  /// In fr, this message translates to:
  /// **'EduVoice est conçu selon les critères WCAG 2.1 AA et les meilleures pratiques d\'accessibilité pour les lecteurs d\'écran. Chaque écran est entièrement navigable à la voix et au toucher.'**
  String get aboutA11yBody;

  /// No description provided for @aboutTeamTitle.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get aboutTeamTitle;

  /// No description provided for @aboutTeamBody.
  ///
  /// In fr, this message translates to:
  /// **'Développé par l\'équipe PFE — Projet de Fin d\'Études en ingénierie logicielle.'**
  String get aboutTeamBody;

  /// No description provided for @aboutContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactBody.
  ///
  /// In fr, this message translates to:
  /// **'contact@eduvoice.app'**
  String get aboutContactBody;

  /// No description provided for @radioSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un flux radio'**
  String get radioSearchLabel;

  /// No description provided for @radioSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le nom du flux'**
  String get radioSearchHint;

  /// No description provided for @radioSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get radioSearchPlaceholder;

  /// No description provided for @radioEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun flux radio trouvé.'**
  String get radioEmpty;

  /// No description provided for @radioLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des flux radio'**
  String get radioLoading;

  /// No description provided for @radioCountTts.
  ///
  /// In fr, this message translates to:
  /// **'{count} flux radio trouvés.'**
  String radioCountTts(int count);

  /// No description provided for @radioErrorTts.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors du chargement des flux radio. Veuillez réessayer.'**
  String get radioErrorTts;

  /// No description provided for @radioTileSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Flux Radio : {name}. {description}. Appuyez deux fois pour écouter.'**
  String radioTileSemantics(String name, String description);

  /// No description provided for @radioPlayerOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture du flux radio : {name}.'**
  String radioPlayerOpening(String name);

  /// No description provided for @radioPlayerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description du flux : {desc}'**
  String radioPlayerDescription(String desc);

  /// No description provided for @radioPlayerTranscript.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get radioPlayerTranscript;

  /// No description provided for @radioPlayerNoAudio.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier audio disponible. Vous pouvez écouter la description lue par la synthèse vocale.'**
  String get radioPlayerNoAudio;

  /// No description provided for @radioPlayerListen.
  ///
  /// In fr, this message translates to:
  /// **'Écouter le flux'**
  String get radioPlayerListen;

  /// No description provided for @voiceErrorTts.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur de connexion s\'est produite. Veuillez réessayer.'**
  String get voiceErrorTts;

  /// No description provided for @voiceGoodbyeTts.
  ///
  /// In fr, this message translates to:
  /// **'Session terminée.'**
  String get voiceGoodbyeTts;

  /// No description provided for @notificationArrived.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle notification est survenue.'**
  String get notificationArrived;

  /// No description provided for @homeNotificationSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les notifications'**
  String get homeNotificationSemantics;

  /// No description provided for @notificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @notificationEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification pour le moment.'**
  String get notificationEmpty;

  /// No description provided for @notificationDeleteSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la notification'**
  String get notificationDeleteSemantics;

  /// No description provided for @notificationOpening.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture des notifications'**
  String get notificationOpening;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileTitle;

  /// No description provided for @profileTts.
  ///
  /// In fr, this message translates to:
  /// **'Page profil. Consultez vos informations et gérez votre compte.'**
  String get profileTts;

  /// No description provided for @profileFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get profileFirstName;

  /// No description provided for @profileLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get profileLastName;

  /// No description provided for @profileLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get profileLevel;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get profileConfirmPassword;

  /// No description provided for @profileChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileChangePassword;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profilePasswordSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès.'**
  String get profilePasswordSuccess;

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas. Veuillez réessayer.'**
  String get profilePasswordMismatch;

  /// No description provided for @profileNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur réseau s\'est produite. Veuillez réessayer.'**
  String get profileNetworkError;

  /// No description provided for @profilePasswordLoading.
  ///
  /// In fr, this message translates to:
  /// **'Modification du mot de passe en cours, veuillez patienter.'**
  String get profilePasswordLoading;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion en cours. Au revoir.'**
  String get profileLogoutConfirm;

  /// No description provided for @profileSectionInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get profileSectionInfo;

  /// No description provided for @profileSectionSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileSectionSecurity;

  /// No description provided for @profileFirstNameSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ prénom'**
  String get profileFirstNameSemantics;

  /// No description provided for @profileLastNameSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ nom'**
  String get profileLastNameSemantics;

  /// No description provided for @profileLevelSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Votre niveau actuel'**
  String get profileLevelSemantics;

  /// No description provided for @profileCurrentPasswordSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ mot de passe actuel'**
  String get profileCurrentPasswordSemantics;

  /// No description provided for @profileNewPasswordSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ nouveau mot de passe'**
  String get profileNewPasswordSemantics;

  /// No description provided for @profileConfirmPasswordSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Champ confirmer le nouveau mot de passe'**
  String get profileConfirmPasswordSemantics;

  /// No description provided for @profileChangePasswordSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Bouton changer le mot de passe. Appuyez deux fois pour confirmer.'**
  String get profileChangePasswordSemantics;

  /// No description provided for @profileLogoutSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Bouton se déconnecter. Appuyez deux fois pour quitter l\'application.'**
  String get profileLogoutSemantics;

  /// No description provided for @profileOldPasswordError.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe actuel est incorrect.'**
  String get profileOldPasswordError;

  /// No description provided for @offlineSemanticsAnnouncement.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Veuillez appuyer deux fois sur le bouton réessayer au bas de l\'écran pour tenter à nouveau.'**
  String get offlineSemanticsAnnouncement;

  /// No description provided for @offlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier votre connexion internet ou vos données mobiles.'**
  String get offlineMessage;

  /// No description provided for @offlineRetryButton.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get offlineRetryButton;

  /// No description provided for @offlineRetryHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez deux fois pour vérifier à nouveau la connexion internet'**
  String get offlineRetryHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
