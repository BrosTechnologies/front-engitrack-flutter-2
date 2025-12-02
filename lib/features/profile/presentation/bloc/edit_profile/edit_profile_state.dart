// lib/features/profile/presentation/bloc/edit_profile/edit_profile_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

/// Estados del EditProfileBloc
class EditProfileState extends Equatable {
  final String fullName;
  final String? phone;
  final String? email;
  final String? role;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String? fullNameError;
  final String? phoneError;
  final UserProfile? savedProfile;

  const EditProfileState({
    this.fullName = '',
    this.phone,
    this.email,
    this.role,
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.fullNameError,
    this.phoneError,
    this.savedProfile,
  });

  /// Estado inicial
  factory EditProfileState.initial() {
    return const EditProfileState();
  }

  /// El formulario es válido si el nombre no está vacío y no hay errores
  bool get isValid => 
      fullName.trim().isNotEmpty && 
      fullName.trim().length >= 3 &&
      fullNameError == null;

  /// Hay cambios sin guardar
  bool hasChanges(String originalName, String? originalPhone) {
    return fullName.trim() != originalName.trim() ||
        (phone ?? '').trim() != (originalPhone ?? '').trim();
  }

  EditProfileState copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? role,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? fullNameError,
    String? phoneError,
    UserProfile? savedProfile,
    bool clearErrors = false,
    bool clearPhone = false,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      phone: clearPhone ? null : (phone ?? this.phone),
      email: email ?? this.email,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: clearErrors ? null : errorMessage,
      fullNameError: clearErrors ? null : (fullNameError ?? this.fullNameError),
      phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
      savedProfile: savedProfile ?? this.savedProfile,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        phone,
        email,
        role,
        isLoading,
        isSaving,
        saveSuccess,
        errorMessage,
        fullNameError,
        phoneError,
        savedProfile,
      ];
}
