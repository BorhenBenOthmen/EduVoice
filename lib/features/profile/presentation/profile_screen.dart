// lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/audio/tts_service.dart';
import '../../../core/auth/token_manager.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../../../features/auth/presentation/login_screen.dart';
import '../../../features/voice_commander/data/gemini_routing_service.dart';
import '../../../injection_container.dart';
import '../../../l10n/app_localizations.dart';
import 'state/profile_cubit.dart';
import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry-point helper: wraps the screen with its own Cubit
// ─────────────────────────────────────────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        tokenManager: locator<TokenManager>(),
        authRepository: locator<AuthRepository>(),
      )..loadProfile(),
      child: const ProfileScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actual screen
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _tts = GetIt.I<TtsService>();

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Focus nodes for screen-reader keyboard flow
  final _oldPassFocus = FocusNode();
  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  /// Controls whether the three password fields are visible.
  /// Hidden by default so TalkBack users don't have to swipe past them.
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    // Speak welcome TTS after the first frame so Localizations is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context);
      if (l != null) {
        _tts.speakWithDelay(l.profileTts);
      }
    });
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _oldPassFocus.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  // ── Logout helper ──────────────────────────────────────────────────────────
  Future<void> _handleLogout(BuildContext ctx, AppLocalizations l) async {
    // 1. Capture cubit reference BEFORE any await to avoid BuildContext-across-gap
    final cubit = ctx.read<ProfileCubit>();

    // 2. Announce to screen reader
    await _tts.speak(l.profileLogoutConfirm);

    // 3. Disconnect the AI WebSocket to prevent background audio leaks
    locator<GeminiRoutingService>().disconnect();

    // 4. Clear all tokens (delegates to AuthRepository)
    await cubit.logout();

    if (!mounted) return;

    // 5. Navigate to Login — push-and-remove-all so Back swipe cannot re-enter
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ── Show / hide password fields ────────────────────────────────────────────
  void _togglePasswordFields(AppLocalizations l) {
    setState(() => _showPasswordFields = !_showPasswordFields);
    if (_showPasswordFields) {
      // Announce that the form is now open
      _tts.speakWithDelay(l.profileCurrentPassword);
      // Move focus to the first field after a short delay
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        FocusScope.of(context).requestFocus(_oldPassFocus);
      });
    } else {
      // Clear fields when collapsing
      _oldPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
    }
  }

  // ── Password change submit ─────────────────────────────────────────────────
  void _handleChangePassword(BuildContext ctx) {
    ctx.read<ProfileCubit>().changePassword(
      oldPassword: _oldPassController.text,
      newPassword: _newPassController.text,
      confirmPassword: _confirmPassController.text,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (ctx, state) async {
        // ── TTS announcements for every meaningful state change ────────────
        if (state is PasswordChangeLoading) {
          await _tts.speak(l.profilePasswordLoading);
        } else if (state is PasswordChangeSuccess) {
          // Collapse & clear the password fields on success
          setState(() => _showPasswordFields = false);
          _oldPassController.clear();
          _newPassController.clear();
          _confirmPassController.clear();
          await _tts.speak(l.profilePasswordSuccess);
        } else if (state is ProfileError) {
          final message = _errorMessage(l, state.errorCode);
          await _tts.speak(message);
        }
      },
      builder: (ctx, state) {
        // ── Derive display values from whichever state is active ───────────
        String firstName = '';
        String lastName = '';
        String levelName = '';
        bool isLoading = false;

        if (state is ProfileLoading) {
          isLoading = true;
        } else if (state is ProfileLoaded) {
          firstName = state.firstName;
          lastName = state.lastName;
          levelName = state.levelName;
        } else if (state is PasswordChangeLoading) {
          firstName = state.firstName;
          lastName = state.lastName;
          levelName = state.levelName;
          isLoading = true;
        } else if (state is PasswordChangeSuccess) {
          firstName = state.firstName;
          lastName = state.lastName;
          levelName = state.levelName;
        } else if (state is ProfileError) {
          firstName = state.firstName;
          lastName = state.lastName;
          levelName = state.levelName;
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            // Back button — auto-generated, fully accessible via TalkBack
            title: Semantics(
              header: true,
              child: Text(
                l.profileTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(color: AppTheme.darkTeal, height: 2.0),
            ),
          ),
          body: isLoading && state is ProfileLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.darkTeal),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Section: Account Information ─────────────────
                        _SectionHeader(title: l.profileSectionInfo),
                        const SizedBox(height: 16),

                        // Avatar + name display
                        Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.darkTeal,
                                width: 3,
                              ),
                              color: AppTheme.cream,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 52,
                              color: AppTheme.darkTeal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // First Name
                        Semantics(
                          label: l.profileFirstNameSemantics,
                          readOnly: true,
                          child: _InfoTile(
                            icon: Icons.badge_outlined,
                            label: l.profileFirstName,
                            value: firstName.isEmpty ? '—' : firstName,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Last Name
                        Semantics(
                          label: l.profileLastNameSemantics,
                          readOnly: true,
                          child: _InfoTile(
                            icon: Icons.person_outline,
                            label: l.profileLastName,
                            value: lastName.isEmpty ? '—' : lastName,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Level
                        Semantics(
                          label: l.profileLevelSemantics,
                          readOnly: true,
                          child: _InfoTile(
                            icon: Icons.school_outlined,
                            label: l.profileLevel,
                            value: levelName.isEmpty ? '—' : levelName,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Section: Change Password ──────────────────────
                        _SectionHeader(title: l.profileSectionSecurity),
                        const SizedBox(height: 16),

                        // Success banner (always visible even when fields are hidden)
                        if (state is PasswordChangeSuccess)
                          _SuccessBanner(message: l.profilePasswordSuccess),

                        // ── Toggle button — shown when fields are HIDDEN ──
                        if (!_showPasswordFields)
                          Semantics(
                            button: true,
                            label: l.profileChangePasswordSemantics,
                            child: SizedBox(
                              height: 72,
                              child: OutlinedButton.icon(
                                key: const Key('profile_toggle_password_btn'),
                                onPressed: () => _togglePasswordFields(l),
                                icon: const Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.darkTeal,
                                  size: 26,
                                ),
                                label: Text(
                                  l.profileChangePassword,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkTeal,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppTheme.darkTeal,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // ── Expanded form — shown when fields are VISIBLE ─
                        if (_showPasswordFields) ...[
                          // Error banner inside the form
                          if (state is ProfileError)
                            _ErrorBanner(
                              message: _errorMessage(l, state.errorCode),
                            ),

                          const SizedBox(height: 8),

                          // Current password
                          Semantics(
                            label: l.profileCurrentPasswordSemantics,
                            textField: true,
                            child: _PasswordField(
                              id: 'profile_current_password',
                              controller: _oldPassController,
                              focusNode: _oldPassFocus,
                              label: l.profileCurrentPassword,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_newPassFocus),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // New password
                          Semantics(
                            label: l.profileNewPasswordSemantics,
                            textField: true,
                            child: _PasswordField(
                              id: 'profile_new_password',
                              controller: _newPassController,
                              focusNode: _newPassFocus,
                              label: l.profileNewPassword,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_confirmPassFocus),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirm password
                          Semantics(
                            label: l.profileConfirmPasswordSemantics,
                            textField: true,
                            child: _PasswordField(
                              id: 'profile_confirm_password',
                              controller: _confirmPassController,
                              focusNode: _confirmPassFocus,
                              label: l.profileConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleChangePassword(ctx),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Submit button
                          Semantics(
                            button: true,
                            label: l.profileChangePasswordSemantics,
                            child: SizedBox(
                              height: 72,
                              child: ElevatedButton(
                                key: const Key('profile_change_password_btn'),
                                onPressed: isLoading
                                    ? null
                                    : () => _handleChangePassword(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.darkTeal,
                                  foregroundColor: AppTheme.cream,
                                  disabledBackgroundColor: AppTheme.darkTeal
                                      .withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.cream,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Text(
                                        l.profileChangePassword,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Cancel / hide fields button
                          Semantics(
                            button: true,
                            label: 'Annuler',
                            child: SizedBox(
                              height: 60,
                              child: TextButton(
                                key: const Key('profile_cancel_password_btn'),
                                onPressed: isLoading
                                    ? null
                                    : () => _togglePasswordFields(l),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppTheme.darkTeal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),
                        const Divider(color: AppTheme.navy, thickness: 1),
                        const SizedBox(height: 24),

                        // ── Logout button ─────────────────────────────────
                        Semantics(
                          button: true,
                          label: l.profileLogoutSemantics,
                          child: SizedBox(
                            height: 72,
                            child: OutlinedButton.icon(
                              key: const Key('profile_logout_btn'),
                              onPressed: () => _handleLogout(ctx, l),
                              icon: Icon(
                                Icons.logout,
                                color: Colors.red.shade700,
                                size: 28,
                              ),
                              label: Text(
                                l.profileLogout,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.shade700,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// Maps a Cubit error code to a user-facing localized message.
  String _errorMessage(AppLocalizations l, String code) {
    switch (code) {
      case 'mismatch':
        return l.profilePasswordMismatch;
      case 'old_wrong':
        return l.profileOldPasswordError;
      default:
        return l.profileNetworkError;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Yellow section header (matches Settings screen style).
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkTeal,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Read-only info tile (name, level).
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        border: Border.all(color: AppTheme.darkTeal, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.navy, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: AppTheme.darkTeal),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// High-contrast password text field.
class _PasswordField extends StatelessWidget {
  final String id;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    required this.id,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key(id),
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 20, color: AppTheme.navy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18, color: AppTheme.darkTeal),
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.darkTeal),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.navy, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }
}

/// Red error banner with icon.
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        border: Border.all(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.navy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green success banner.
class _SuccessBanner extends StatelessWidget {
  final String message;
  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        border: Border.all(color: Colors.green.shade800, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade800,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.navy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
