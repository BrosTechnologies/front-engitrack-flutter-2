// lib/features/auth/presentation/bloc/change_password/change_password_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

/// Bloc para cambio de contraseña de usuario autenticado
class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository _authRepository;

  ChangePasswordBloc(this._authRepository) : super(const ChangePasswordInitial()) {
    on<ChangePasswordSubmit>(_onChangePasswordSubmit);
    on<ResetChangePasswordState>(_onResetState);
  }

  /// Cambiar contraseña
  Future<void> _onChangePasswordSubmit(
    ChangePasswordSubmit event,
    Emitter<ChangePasswordState> emit,
  ) async {
    // Validaciones
    if (event.currentPassword.isEmpty) {
      emit(const ChangePasswordError('Por favor ingresa tu contraseña actual'));
      return;
    }

    if (event.newPassword.isEmpty) {
      emit(const ChangePasswordError('Por favor ingresa una nueva contraseña'));
      return;
    }

    if (event.newPassword.length < 6) {
      emit(const ChangePasswordError('La nueva contraseña debe tener al menos 6 caracteres'));
      return;
    }

    if (event.currentPassword == event.newPassword) {
      emit(const ChangePasswordError('La nueva contraseña debe ser diferente a la actual'));
      return;
    }

    emit(const ChangePasswordLoading());

    final result = await _authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordError(failure.message)),
      (_) => emit(const ChangePasswordSuccess()),
    );
  }

  /// Reiniciar estado
  Future<void> _onResetState(
    ResetChangePasswordState event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(const ChangePasswordInitial());
  }
}
