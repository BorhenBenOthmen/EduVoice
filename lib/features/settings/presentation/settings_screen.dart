import 'package:flutter/material.dart';
import '../../../core/locale/locale_service.dart';
import '../../../core/audio/tts_service.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../about/presentation/about_screen.dart';



/// Full-featured Settings screen for EduVoice — designed for blind users.
///
/// Every interactive element has:
///   • A [Semantics] label announcing its purpose.
///   • A TTS confirmation on state change.
///   • Large touch targets (min 80 px height).
///   • High-contrast colour scheme (cyan-on-black / amber-on-black).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _locale = locator<LocaleService>();
  final _tts = locator<TtsService>();

  late int _speedIndex;
  late double _volume;

  // Speeds roughly match: slow (0.4), normal (0.5), fast (0.9)
  // Our new default from TTS is 0.5 for normal, so let's adjust the array
  // Or handle matching carefully
  static const _speeds = [0.4, 0.5, 0.9];

  @override
  void initState() {
    super.initState();
    _volume = _tts.currentVolume;
    _speedIndex = _speeds.indexOf(_tts.currentRate);
    if (_speedIndex == -1) {
      if (_tts.currentRate < 0.5) _speedIndex = 0;
      else if (_tts.currentRate > 0.5) _speedIndex = 2;
      else _speedIndex = 1;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      _tts.speak(l.settingsTts);
    });
  }

  Future<void> _changeLanguage(String code, String langName) async {
    try {
      // 1. Stop any in-progress TTS so the native engine is idle.
      await _tts.stop();

      // 2. Pre-load localization strings BEFORE the locale change.
      final newLocalizations = await AppLocalizations.delegate.load(Locale(code));

      // 3. Set TTS language while everything is calm.
      final langSet = await _tts.setLanguage(code);
      if (!langSet) {
        debugPrint('SettingsScreen: TTS voice for $code not available');
      }

      if (!mounted) return;

      // 4. CRITICAL: Temporarily disable the accessibility tree so TalkBack
      //    releases all native references to accessibility nodes.
      //    Without this, TalkBack crashes when the LTR↔RTL Directionality
      //    rebuild destroys and recreates all Semantics nodes.
      EduVoiceApp.semanticsEnabled.value = false;

      // Give TalkBack a moment to release its node references.
      await Future.delayed(const Duration(milliseconds: 150));

      // 5. NOW change the locale — the rebuild is safe because TalkBack
      //    has no accessibility nodes to reference.
      await _locale.setLocale(code);

      // 6. Wait for the widget tree rebuild to fully settle.
      await Future.delayed(const Duration(milliseconds: 400));

      // 7. Re-enable the accessibility tree with the fresh nodes.
      EduVoiceApp.semanticsEnabled.value = true;

      // 8. Give TalkBack time to pick up the new nodes.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      await _tts.speak(newLocalizations.settingsLanguageChanged(langName));
    } catch (e) {
      debugPrint('SettingsScreen: Error changing language: $e');
      // Ensure semantics are always re-enabled even on error.
      EduVoiceApp.semanticsEnabled.value = true;
    }
  }

  Future<void> _changeSpeed(int index) async {
    // Capture localizations BEFORE the first await (BuildContext safety)
    final l = AppLocalizations.of(context)!;
    setState(() => _speedIndex = index);
    await _tts.setRate(_speeds[index]);
    final speedNames = [
      l.settingsTtsSpeedSlow,
      l.settingsTtsSpeedNormal,
      l.settingsTtsSpeedFast,
    ];
    await _tts.speak(l.settingsTtsSpeedChanged(speedNames[index]));
    await _tts.speak(l.settingsTtsTest);
  }

  Future<void> _changeVolume(double value) async {
    // Capture localizations BEFORE the first await (BuildContext safety)
    final l = AppLocalizations.of(context)!;
    setState(() => _volume = value);
    await _tts.setVolume(value);
    await _tts.speak(l.settingsTtsVolumeChanged((value * 100).round()));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final currentCode = _locale.current.languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          l.settingsTitle,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.cyanAccent, height: 2.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ─── LANGUAGE SECTION ─────────────────────────────────────
            _SectionHeader(title: l.settingsLanguageSection),
            const SizedBox(height: 8),
            Row(
              children: [
                _LanguageTile(
                  label: l.settingsLanguageAr,
                  semanticsLabel: l.settingsLanguageArSemantics,
                  selectedLabel: l.settingsLanguageSelected,
                  code: 'ar',
                  isActive: currentCode == 'ar',
                  onTap: () => _changeLanguage('ar', l.settingsLanguageAr),
                ),
                const SizedBox(width: 8),
                _LanguageTile(
                  label: l.settingsLanguageFr,
                  semanticsLabel: l.settingsLanguageFrSemantics,
                  selectedLabel: l.settingsLanguageSelected,
                  code: 'fr',
                  isActive: currentCode == 'fr',
                  onTap: () => _changeLanguage('fr', l.settingsLanguageFr),
                ),
                const SizedBox(width: 8),
                _LanguageTile(
                  label: l.settingsLanguageEn,
                  semanticsLabel: l.settingsLanguageEnSemantics,
                  selectedLabel: l.settingsLanguageSelected,
                  code: 'en',
                  isActive: currentCode == 'en',
                  onTap: () => _changeLanguage('en', l.settingsLanguageEn),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ─── VOICE & AUDIO SECTION ────────────────────────────────
            _SectionHeader(title: l.settingsTtsSection),
            const SizedBox(height: 16),

            // TTS Speed
            Text(
              l.settingsTtsSpeed,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.amberAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _SpeedTile(
                  label: l.settingsTtsSpeedSlow,
                  isActive: _speedIndex == 0,
                  onTap: () => _changeSpeed(0),
                ),
                const SizedBox(width: 8),
                _SpeedTile(
                  label: l.settingsTtsSpeedNormal,
                  isActive: _speedIndex == 1,
                  onTap: () => _changeSpeed(1),
                ),
                const SizedBox(width: 8),
                _SpeedTile(
                  label: l.settingsTtsSpeedFast,
                  isActive: _speedIndex == 2,
                  onTap: () => _changeSpeed(2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // TTS Volume
            Text(
              l.settingsTtsVolume,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.amberAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '${l.settingsTtsVolume}: ${(_volume * 100).round()}%',
              slider: true,
              value: '${(_volume * 100).round()}%',
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.cyanAccent,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.cyanAccent,
                  overlayColor: Colors.cyanAccent.withAlpha(30),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _volume,
                  min: 0.3,
                  max: 1.0,
                  divisions: 7,
                  onChanged: (v) => setState(() => _volume = v),
                  onChangeEnd: _changeVolume,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${(_volume * 100).round()}%',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 40),

            // ─── ABOUT SECTION ────────────────────────────────────────
            Semantics(
              label: l.settingsAboutSemantics,
              button: true,
              excludeSemantics: true,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[900],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l.settingsAboutButton,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54, size: 28),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Private helper widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          letterSpacing: 1.8,
          color: Colors.cyanAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final String selectedLabel;
  final String code;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.semanticsLabel,
    required this.selectedLabel,
    required this.code,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$semanticsLabel ${isActive ? "($selectedLabel)" : ""}',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isActive ? Colors.cyanAccent : Colors.grey[700]!,
                  width: isActive ? 3 : 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isActive ? Colors.cyanAccent.withAlpha(25) : Colors.grey[900],
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: code == 'ar' ? 18 : 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.cyanAccent : Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SpeedTile({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? Colors.amberAccent : Colors.grey[700]!,
                width: isActive ? 3 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isActive ? Colors.amberAccent.withAlpha(25) : Colors.grey[900],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.amberAccent : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
