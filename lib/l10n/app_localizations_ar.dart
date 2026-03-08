// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'EduVoice';

  @override
  String get welcomeMessage => 'مرحباً بك في EduVoice. منصة التعلم للجميع.';

  @override
  String get loginTitle => 'تسجيل الدخول إلى EduVoice';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول، يرجى الانتظار.';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح. مرحباً بك في EduVoice.';

  @override
  String get loginError =>
      'فشل تسجيل الدخول. البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مجدداً.';

  @override
  String get loginEmptyFields => 'خطأ. البريد الإلكتروني وكلمة المرور مطلوبان.';

  @override
  String get loginEmailSemantics => 'حقل إدخال البريد الإلكتروني';

  @override
  String get loginPasswordSemantics => 'حقل إدخال كلمة المرور';

  @override
  String get loginButtonSemantics => 'زر تسجيل الدخول. انقر مرتين للتأكيد.';

  @override
  String get homeCatalogueTitle => 'EduVoice';

  @override
  String get homeWelcomeTts =>
      'مرحباً بك في EduVoice. اختر قسماً: الدروس، الثقافة، البودكاست، أو الراديو.';

  @override
  String get homeMenuLesson => 'الدروس';

  @override
  String get homeMenuLessonDesc => 'دروس صوتية تفاعلية';

  @override
  String get homeMenuCulture => 'الثقافة';

  @override
  String get homeMenuCultureDesc => 'اكتشافات ثقافية';

  @override
  String get homeMenuPodcast => 'البودكاست';

  @override
  String get homeMenuPodcastDesc => 'حلقات مختارة';

  @override
  String get homeMenuRadio => 'الراديو';

  @override
  String get homeMenuRadioDesc => 'بث مباشر';

  @override
  String get homeMenuLessonSemantics => 'قسم الدروس. انقر مرتين للفتح.';

  @override
  String get homeMenuCultureSemantics => 'قسم الثقافة. انقر مرتين للفتح.';

  @override
  String get homeMenuPodcastSemantics => 'قسم البودكاست. انقر مرتين للفتح.';

  @override
  String get homeMenuRadioSemantics => 'قسم الراديو. انقر مرتين للفتح.';

  @override
  String get homeListeningButton => 'التسجيل جارٍ. انقر مرتين للإيقاف.';

  @override
  String get homeMicButton => 'المساعد الصوتي. انقر مرتين لطرح سؤال.';

  @override
  String get homeVoiceDefault => 'استخدم زر الميكروفون للتحدث.';

  @override
  String get homeSearching => 'جارٍ البحث';

  @override
  String get homeListening => 'أنا أستمع إليك';

  @override
  String homeCourseSemantics(String title, String description) {
    return 'دورة: $title. $description. انقر مرتين للفتح.';
  }

  @override
  String get homeAboutSemantics => 'حول تطبيق EduVoice';

  @override
  String get homeSettingsSemantics => 'إعدادات التطبيق';

  @override
  String get homeOpeningAbout => 'فتح صفحة حول التطبيق.';

  @override
  String get homeOpeningSettings => 'فتح الإعدادات.';

  @override
  String homeOpeningSection(String title) {
    return 'فتح قسم: $title.';
  }

  @override
  String get lessonTitle => 'الدروس';

  @override
  String get lessonSearchLabel => 'البحث عن درس';

  @override
  String get lessonSearchHint => 'أدخل اسم الدرس للبحث';

  @override
  String get lessonSearchPlaceholder => 'بحث...';

  @override
  String get lessonEmpty => 'لا توجد دروس مطابقة.';

  @override
  String get lessonLoading => 'جارٍ تحميل الدروس';

  @override
  String lessonCountTts(int count) {
    return 'تم العثور على $count دروس.';
  }

  @override
  String get lessonErrorTts =>
      'حدث خطأ أثناء تحميل الدروس. يرجى المحاولة مرة أخرى.';

  @override
  String lessonTileSemantics(String name, String description) {
    return 'درس: $name. $description. انقر مرتين للاستماع.';
  }

  @override
  String lessonPlayerOpening(String name) {
    return 'فتح درس: $name.';
  }

  @override
  String lessonPlayerDescription(String desc) {
    return 'وصف الدرس: $desc';
  }

  @override
  String get lessonPlayerTranscript => 'النص المكتوب';

  @override
  String get lessonPlayerNoAudio =>
      'لا يوجد ملف صوتي متاح. يمكنك الاستماع للوصف بالنص المقروء.';

  @override
  String get lessonPlayerPlay => 'تشغيل';

  @override
  String get lessonPlayerPause => 'إيقاف مؤقت';

  @override
  String get lessonPlayerStop => 'إيقاف التشغيل وإعادة للبداية';

  @override
  String get lessonPlayerReplay => 'رجوع 10 ثوانٍ';

  @override
  String get lessonPlayerFastForward => 'تقديم 10 ثوانٍ';

  @override
  String get lessonPlayerRewind => 'رجوع 10 ثوانٍ';

  @override
  String get lessonPlayerSpeedIncrease => 'زيادة سرعة التشغيل';

  @override
  String get lessonPlayerSpeedDecrease => 'تقليل سرعة التشغيل';

  @override
  String lessonPlayerCurrentSpeed(String speed) {
    return 'السرعة ${speed}x';
  }

  @override
  String get lessonPlayerListen => 'استمع للدرس';

  @override
  String get lessonPlayerStopTts => 'إيقاف الاستماع';

  @override
  String get lessonPlayerStopLabel => 'إيقاف الاستماع. انقر مرتين للإيقاف.';

  @override
  String get lessonPlayerListenLabel =>
      'بدء الاستماع للدرس بصوت عالٍ. انقر مرتين للتشغيل.';

  @override
  String get podcastTitle => 'البودكاست';

  @override
  String get podcastTts => 'قسم البودكاست. قريباً — حلقات مختارة لتعزيز تعلمك.';

  @override
  String get podcastComingSoon => 'قريباً';

  @override
  String get podcastComingSoonDesc =>
      'ستتوفر بودكاست متنوعة ومفيدة قريباً جداً.';

  @override
  String get radioTitle => 'الراديو';

  @override
  String get radioTts => 'قسم الراديو. قريباً — بث تعليمي مباشر.';

  @override
  String get radioComingSoon => 'قريباً';

  @override
  String get radioComingSoonDesc =>
      'ستتوفر قنوات راديو تعليمية مباشرة قريباً جداً.';

  @override
  String get cultureTitle => 'الثقافة';

  @override
  String get cultureTts =>
      'قسم الثقافة. قريباً — استكشف العالم من خلال روايات ثقافية.';

  @override
  String get cultureComingSoon => 'قريباً';

  @override
  String get cultureComingSoonDesc => 'ستتوفر محتويات ثقافية ثرية قريباً جداً.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsTts => 'فتح إعدادات التطبيق.';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String settingsLanguageChanged(String lang) {
    return 'تم تغيير اللغة إلى $lang.';
  }

  @override
  String get settingsTtsSection => 'الصوت والصوت';

  @override
  String get settingsTtsSpeed => 'سرعة القراءة';

  @override
  String get settingsTtsSpeedSlow => 'بطيئة';

  @override
  String get settingsTtsSpeedNormal => 'عادية';

  @override
  String get settingsTtsSpeedFast => 'سريعة';

  @override
  String settingsTtsSpeedChanged(String speed) {
    return 'تم تغيير سرعة القراءة إلى $speed.';
  }

  @override
  String get settingsTtsVolume => 'مستوى الصوت';

  @override
  String settingsTtsVolumeChanged(int percent) {
    return 'تم ضبط مستوى الصوت على $percent بالمئة.';
  }

  @override
  String get settingsTtsTest => 'هكذا أقرأ المحتوى من أجلك.';

  @override
  String get settingsAboutButton => 'حول التطبيق';

  @override
  String get settingsAboutSemantics => 'الانتقال إلى صفحة حول التطبيق';

  @override
  String get aboutTitle => 'حول EduVoice';

  @override
  String get aboutTts =>
      'صفحة حول التطبيق. EduVoice هي منصة تعلم متاحة للمكففين. الإصدار واحد نقطة صفر. مهمتنا هي تمكين جميع المتعلمين من خلال التعليم الصوتي.';

  @override
  String get aboutVersionLabel => 'الإصدار';

  @override
  String get aboutVersion => '1.0.0';

  @override
  String get aboutMissionTitle => 'مهمتنا';

  @override
  String get aboutMissionBody =>
      'تمكين المتعلمين ذوي الإعاقة البصرية من خلال التعليم الصوتي.';

  @override
  String get aboutFeaturesTitle => 'المميزات';

  @override
  String get aboutFeature1 => '📚  دروس صوتية تفاعلية';

  @override
  String get aboutFeature2 => '📻  راديو تعليمي مباشر';

  @override
  String get aboutFeature3 => '🎙️  بودكاست مختار';

  @override
  String get aboutFeature4 => '🌍  المستكشف الثقافي';

  @override
  String get aboutFeature5 => '🎤  أوامر صوتية';

  @override
  String get aboutA11yTitle => 'الإتاحة';

  @override
  String get aboutA11yBody =>
      'صُمّمت EduVoice وفق معايير WCAG 2.1 AA وأفضل ممارسات قارئات الشاشة. كل شاشة قابلة للتنقل الكامل بالصوت واللمس.';

  @override
  String get aboutTeamTitle => 'الفريق';

  @override
  String get aboutTeamBody =>
      'طوّره فريق PFE — مشروع التخرج في هندسة البرمجيات.';

  @override
  String get aboutContactTitle => 'التواصل';

  @override
  String get aboutContactBody => 'contact@eduvoice.app';
}
