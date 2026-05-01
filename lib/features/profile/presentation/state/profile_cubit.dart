// lib/features/profile/presentation/state/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../auth/data/auth_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final TokenManager _tokenManager;
  final AuthRepository _authRepository;

  // Cache profile data so it survives state transitions (loading → success/error).
  String _firstName = '';
  String _lastName = '';
  String _levelName = '';

  ProfileCubit({
    required TokenManager tokenManager,
    required AuthRepository authRepository,
  })  : _tokenManager = tokenManager,
        _authRepository = authRepository,
        super(ProfileLoading());

  /// Reads profile info from local secure storage (no network call).
  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final rawName = await _tokenManager.getFirstName() ?? '';
    _firstName = rawName;
    _lastName = await _tokenManager.getLastName() ?? '';

    _levelName = await _tokenManager.getLevelName() ?? '';

    emit(ProfileLoaded(
      firstName: _firstName,
      lastName: _lastName,
      levelName: _levelName,
    ));
  }

  /// Validates passwords client-side then delegates to [AuthRepository].
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // --- Client-side validation ---
    if (newPassword != confirmPassword) {
      emit(ProfileError(
        errorCode: 'mismatch',
        firstName: _firstName,
        lastName: _lastName,
        levelName: _levelName,
      ));
      return;
    }

    emit(PasswordChangeLoading(
      firstName: _firstName,
      lastName: _lastName,
      levelName: _levelName,
    ));

    final errorCode = await _authRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (errorCode == null) {
      emit(PasswordChangeSuccess(
        firstName: _firstName,
        lastName: _lastName,
        levelName: _levelName,
      ));
    } else {
      emit(ProfileError(
        errorCode: errorCode,
        firstName: _firstName,
        lastName: _lastName,
        levelName: _levelName,
      ));
    }
  }

  /// Clears all stored credentials. The UI is responsible for routing.
  Future<void> logout() async {
    await _authRepository.logout();
  }
}
