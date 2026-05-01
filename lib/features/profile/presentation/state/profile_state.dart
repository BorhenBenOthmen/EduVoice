// lib/features/profile/presentation/state/profile_state.dart

part of 'profile_cubit.dart';

/// Base state for the Profile feature.
abstract class ProfileState {}

/// Emitted while reading data from TokenManager on page load.
class ProfileLoading extends ProfileState {}

/// Emitted once local profile data has been read successfully.
class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String levelName;

  ProfileLoaded({
    required this.firstName,
    required this.lastName,
    required this.levelName,
  });
}

/// Emitted while the password-change HTTP request is in flight.
class PasswordChangeLoading extends ProfileState {
  /// We carry the profile data so the UI does not blank out during loading.
  final String firstName;
  final String lastName;
  final String levelName;

  PasswordChangeLoading({
    required this.firstName,
    required this.lastName,
    required this.levelName,
  });
}

/// Emitted when the password was changed successfully.
class PasswordChangeSuccess extends ProfileState {
  final String firstName;
  final String lastName;
  final String levelName;

  PasswordChangeSuccess({
    required this.firstName,
    required this.lastName,
    required this.levelName,
  });
}

/// Emitted on any error (network, wrong old password, mismatch).
class ProfileError extends ProfileState {
  /// One of: 'mismatch', 'old_wrong', 'network'
  final String errorCode;

  /// The profile data so the UI stays intact.
  final String firstName;
  final String lastName;
  final String levelName;

  ProfileError({
    required this.errorCode,
    required this.firstName,
    required this.lastName,
    required this.levelName,
  });
}
