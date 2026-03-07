import 'package:flutter/material.dart';
import '../../../core/audio/tts_service.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';

/// About screen for EduVoice — blind-accessible, fully TTS-narrated on load.
///
/// Accessibility contract:
///   • On mount, [TtsService] reads the entire page summary aloud.
///   • Each section has an explicit [Semantics] label.
///   • Large text sizes and high-contrast colours throughout.
///   • Contact e-mail uses [ExcludeSemantics] wrapper so it isn't
///     double-announced (the section header already introduces it).
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _tts = locator<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      _tts.speak(l.aboutTts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          l.aboutTitle,
          style: const TextStyle(
            fontSize: 24,
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
          padding: const EdgeInsets.all(20),
          children: [
            // ─── HERO BANNER ──────────────────────────────────────────
            Semantics(
              header: true,
              label: 'EduVoice — ${l.aboutVersionLabel} ${l.aboutVersion}',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003055), Color(0xFF001830)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.headphones, size: 64, color: Colors.cyanAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'EduVoice',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l.aboutVersionLabel} ${l.aboutVersion}',
                      style: const TextStyle(fontSize: 18, color: Colors.cyanAccent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ─── MISSION ──────────────────────────────────────────────
            _AboutSection(
              icon: Icons.flag_outlined,
              title: l.aboutMissionTitle,
              body: l.aboutMissionBody,
            ),
            const SizedBox(height: 20),

            // ─── FEATURES ─────────────────────────────────────────────
            Semantics(
              header: true,
              label: l.aboutFeaturesTitle,
              child: _SectionTitle(l.aboutFeaturesTitle),
            ),
            const SizedBox(height: 12),
            for (final feature in [
              l.aboutFeature1,
              l.aboutFeature2,
              l.aboutFeature3,
              l.aboutFeature4,
              l.aboutFeature5,
            ])
              _FeatureTile(text: feature),
            const SizedBox(height: 20),

            // ─── ACCESSIBILITY ────────────────────────────────────────
            _AboutSection(
              icon: Icons.accessibility_new,
              title: l.aboutA11yTitle,
              body: l.aboutA11yBody,
            ),
            const SizedBox(height: 20),

            // ─── TEAM ─────────────────────────────────────────────────
            _AboutSection(
              icon: Icons.group_outlined,
              title: l.aboutTeamTitle,
              body: l.aboutTeamBody,
            ),
            const SizedBox(height: 20),

            // ─── CONTACT ──────────────────────────────────────────────
            Semantics(
              header: true,
              label: '${l.aboutContactTitle}: ${l.aboutContactBody}',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.amberAccent.withAlpha(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, color: Colors.amberAccent, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.aboutContactTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ExcludeSemantics(
                            child: Text(
                              l.aboutContactBody,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Private helper widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: Colors.cyanAccent),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AboutSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $body',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.cyanAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String text;
  const _FeatureTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.cyanAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
