import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../l10n/app_localizations.dart';
import 'splash_screen.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically announce the offline state to screen readers as soon as the screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      if (l != null) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          l.offlineSemanticsAnnouncement,
          TextDirection.ltr,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    
    // EduVoice Color Palette
    const Color cream = Color(0xFFE8E4DA);
    const Color navy = Color(0xFF1A2E38);
    const Color darkTeal = Color(0xFF1C4A52);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children:[
            // Expanded allows the content to center in the available space above the button
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      // Exclude the visual icon from the screen reader so it doesn't just say "image"
                      ExcludeSemantics(
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 120.0,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      Text(
                        l?.offlineTitle ?? "No Connection",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.w900,
                          color: navy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        l?.offlineMessage ?? "Please check your internet or mobile data.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: darkTeal,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Massive Action Button placed at the very bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Semantics(
                button: true,
                label: l?.offlineRetryButton ?? 'Retry Connection',
                hint: l?.offlineRetryHint ?? 'Double tap to check the internet connection again',
                child: SizedBox(
                  width: double.infinity, // Full width
                  height: 64.0, // Well above the 44px minimum touch target for accessibility
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTeal,
                      foregroundColor: cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      debugPrint("Retry button pressed - Re-routing to SplashScreen");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                      );
                    },
                    child: Text(
                      l?.offlineRetryButton ?? "Retry Connection",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
