// lib/features/auth/presentation/bloc/password_recovery/password_recovery_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'password_recovery_event.dart';
import 'password_recovery_state.dart';

/// Bloc para el flujo de recuperación de contraseña
class PasswordRecoveryBloc extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  final AuthRepository _authRepository;

  PasswordRecoveryBloc(this._authRepository) : super(const PasswordRecoveryInitial()) {
    on<RequestResetCode>(_onRequestResetCode);
    on<VerifyCode>(_onVerifyCode);
    on<ResetPasswordSubmit>(_onResetPasswordSubmit);
    on<ResendCode>(_onResendCode);
    on<ResetRecoveryProcess>(_onResetRecoveryProcess);
  }

  /// Solicitar código de recuperación
  Future<void> _onRequestResetCode(
    RequestResetCode event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    final email = event.email.trim().toLowerCase();
    
    if (email.isEmpty) {
      emit(PasswordRecoveryError(
        message: 'Por favor ingresa tu email',
        email: email,
        currentStep: RecoveryStep.email,
      ));
      return;
    }

    emit(SendingResetCode(email: email));

    final result = await _authRepository.forgotPassword(email: email);

    result.fold(
      (failure) => emit(PasswordRecoveryError(
        message: failure.message,
        email: email,
        currentStep: RecoveryStep.email,
      )),
      (_) => emit(ResetCodeSent(email: email)),
    );
  }

  /// Verificar código
  Future<void> _onVerifyCode(
    VerifyCode event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    final code = event.code.trim();
    final email = state.email;

    if (code.isEmpty || code.length != 6) {
      emit(PasswordRecoveryError(
        message: 'El código debe tener 6 dígitos',
        email: email,
        currentStep: RecoveryStep.verifyCode,
      ));
      return;
    }

    emit(VerifyingCode(email: email, code: code));

    final result = await _authRepository.verifyResetCode(
      email: email,
      code: code,
    );

    result.fold(
      (failure) => emit(PasswordRecoveryError(
        message: failure.message,
        email: email,
        currentStep: RecoveryStep.verifyCode,
      )),
      (_) => emit(CodeVerified(email: email, code: code)),
    );
  }

  /// Restablecer contraseña
  Future<void> _onResetPasswordSubmit(
    ResetPasswordSubmit event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    final newPassword = event.newPassword;
    final email = state.email;
    final code = state.code;

    if (code == null) {
      emit(PasswordRecoveryError(
        message: 'Error: código no verificado',
        email: email,
        currentStep: RecoveryStep.verifyCode,
      ));
      return;
    }

    if (newPassword.length < 6) {
      emit(PasswordRecoveryError(
        message: 'La contraseña debe tener al menos 6 caracteres',
        email: email,
        code: code,
        currentStep: RecoveryStep.resetPassword,
      ));
      return;
    }

    emit(ResettingPassword(email: email, code: code));

    final result = await _authRepository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(PasswordRecoveryError(
        message: failure.message,
        email: email,
        code: code,
        currentStep: RecoveryStep.resetPassword,
      )),
      (_) => emit(PasswordResetSuccess(email: email)),
    );
  }

  /// Reenviar código
  Future<void> _onResendCode(
    ResendCode event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    final email = state.email;
    
    if (email.isEmpty) {
      emit(const PasswordRecoveryError(
        message: 'Error: no hay email registrado',
        email: '',
        currentStep: RecoveryStep.email,
      ));
      return;
    }

    emit(SendingResetCode(email: email));

    final result = await _authRepository.forgotPassword(email: email);

    result.fold(
      (failure) => emit(PasswordRecoveryError(
        message: failure.message,
        email: email,
        currentStep: RecoveryStep.verifyCode,
      )),
      (_) => emit(ResetCodeSent(email: email)),
    );
  }

  /// Reiniciar proceso
  Future<void> _onResetRecoveryProcess(
    ResetRecoveryProcess event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(const PasswordRecoveryInitial());
  }
}
