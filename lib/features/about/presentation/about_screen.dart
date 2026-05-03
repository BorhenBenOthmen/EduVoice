import 'package:flutter/material.dart';
import '../../../core/audio/tts_service.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l.aboutTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.cream),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.darkTeal, height: 2.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── HERO BANNER ──────────────────────────────────────────
            Semantics(
              header: true,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003055), Color(0xFF001830)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.darkTeal, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.headphones, size: 64, color: AppTheme.cream),
                    const SizedBox(height: 16),
                    const Text(
                      'EduVoice',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.cream,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l.aboutVersionLabel} ${l.aboutVersion}',
                      style: const TextStyle(fontSize: 18, color: AppTheme.cream),
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
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.darkTeal, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.teal.withAlpha(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, color: AppTheme.navy, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.aboutContactTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.darkTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.aboutContactBody,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppTheme.navy,
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
        Container(width: 4, height: 24, color: AppTheme.darkTeal),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
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
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkTeal, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.navy, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 17,
                color: AppTheme.darkTeal,
                height: 1.5,
              ),
            ),
          ],
        ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String text;
  const _FeatureTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.darkTeal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 18, color: AppTheme.navy),
              ),
            ),
          ],
        ),
    );
  }
}
