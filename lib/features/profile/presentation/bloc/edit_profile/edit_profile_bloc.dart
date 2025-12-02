// lib/features/profile/presentation/bloc/edit_profile/edit_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

/// Bloc para manejar la edición del perfil
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final ProfileRepository _profileRepository;

  EditProfileBloc(this._profileRepository) : super(EditProfileState.initial()) {
    on<InitEditProfileEvent>(_onInit);
    on<UpdateFullNameEvent>(_onUpdateFullName);
    on<UpdatePhoneEvent>(_onUpdatePhone);
    on<SaveProfileEvent>(_onSaveProfile);
  }

  Future<void> _onInit(
    InitEditProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    // Si se pasó un perfil, usarlo
    if (event.profile != null) {
      emit(state.copyWith(
        fullName: event.profile!.fullName,
        phone: event.profile!.phone,
        email: event.profile!.email,
        role: event.profile!.role,
      ));
      return;
    }

    // Si no, cargar del servidor
    emit(state.copyWith(isLoading: true));

    final result = await _profileRepository.getProfile();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        isLoading: false,
        fullName: profile.fullName,
        phone: profile.phone,
        email: profile.email,
        role: profile.role,
      )),
    );
  }

  void _onUpdateFullName(
    UpdateFullNameEvent event,
    Emitter<EditProfileState> emit,
  ) {
    String? error;
    if (event.fullName.trim().isEmpty) {
      error = 'El nombre es requerido';
    } else if (event.fullName.trim().length < 3) {
      error = 'El nombre debe tener al menos 3 caracteres';
    }

    emit(state.copyWith(
      fullName: event.fullName,
      fullNameError: error,
      clearErrors: error == null,
    ));
  }

  void _onUpdatePhone(
    UpdatePhoneEvent event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        errorMessage: 'Por favor completa el nombre correctamente',
      ));
      return;
    }

    emit(state.copyWith(isSaving: true, clearErrors: true));

    final result = await _profileRepository.updateProfile(
      UpdateProfileParams(
        fullName: state.fullName.trim(),
        phone: state.phone?.trim(),
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
        savedProfile: profile,
      )),
    );
  }
}
