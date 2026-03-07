import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the user's preferred locale with persistence.
///
/// - On first launch, falls back to the device's system locale (if supported),
///   then defaults to French.
/// - Persists the choice in [FlutterSecureStorage] so it survives restarts.
/// - Exposes [currentLocaleNotifier] so [MaterialApp] can rebuild reactively
///   without needing a BLoC / Provider — a clean single-responsibility approach.
class LocaleService {
  final FlutterSecureStorage _storage;

  static const _key = 'preferred_locale';
  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
  ];

  late final ValueNotifier<Locale> currentLocaleNotifier;

  LocaleService(this._storage);

  /// Must be called from [setupDependencies] before [runApp].
  Future<void> init() async {
    final saved = await _storage.read(key: _key);
    Locale resolved;

    if (saved != null && _isSupported(saved)) {
      resolved = Locale(saved);
    } else {
      // Try to match the device's system locale.
      final deviceLocale = PlatformDispatcher.instance.locale;
      if (_isSupported(deviceLocale.languageCode)) {
        resolved = Locale(deviceLocale.languageCode);
      } else {
        resolved = const Locale('fr'); // default
      }
    }

    currentLocaleNotifier = ValueNotifier<Locale>(resolved);
  }

  /// Returns the currently active locale.
  Locale get current => currentLocaleNotifier.value;

  /// Changes the active locale and persists it.
  Future<void> setLocale(String languageCode) async {
    if (!_isSupported(languageCode)) return;
    await _storage.write(key: _key, value: languageCode);
    currentLocaleNotifier.value = Locale(languageCode);
  }

  bool _isSupported(String languageCode) =>
      supportedLocales.any((l) => l.languageCode == languageCode);
}
