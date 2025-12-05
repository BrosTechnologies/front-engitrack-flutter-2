// lib/features/auth/presentation/bloc/password_recovery/password_recovery_state.dart

import 'package:equatable/equatable.dart';

/// Paso actual del flujo de recuperación
enum RecoveryStep {
  /// Paso 1: Ingresar email
  email,
  /// Paso 2: Verificar código
  verifyCode,
  /// Paso 3: Nueva contraseña
  resetPassword,
  /// Completado exitosamente
  completed,
}

/// Estados del bloc de recuperación de contraseña
abstract class PasswordRecoveryState extends Equatable {
  /// Email del usuario
  final String email;
  
  /// Código de verificación (si ya fue verificado)
  final String? code;
  
  /// Paso actual del flujo
  final RecoveryStep currentStep;

  const PasswordRecoveryState({
    this.email = '',
    this.code,
    this.currentStep = RecoveryStep.email,
  });

  @override
  List<Object?> get props => [email, code, currentStep];
}

/// Estado inicial
class PasswordRecoveryInitial extends PasswordRecoveryState {
  const PasswordRecoveryInitial() : super(currentStep: RecoveryStep.email);
}

/// Enviando código de recuperación
class SendingResetCode extends PasswordRecoveryState {
  const SendingResetCode({required super.email});
}

/// Código enviado exitosamente
class ResetCodeSent extends PasswordRecoveryState {
  const ResetCodeSent({required super.email})
      : super(currentStep: RecoveryStep.verifyCode);
}

/// Verificando código
class VerifyingCode extends PasswordRecoveryState {
  const VerifyingCode({
    required super.email,
    required String code,
  }) : super(code: code);
}

/// Código verificado exitosamente
class CodeVerified extends PasswordRecoveryState {
  const CodeVerified({
    required super.email,
    required String super.code,
  }) : super(currentStep: RecoveryStep.resetPassword);
}

/// Restableciendo contraseña
class ResettingPassword extends PasswordRecoveryState {
  const ResettingPassword({
    required super.email,
    required String super.code,
  });
}

/// Contraseña restablecida exitosamente
class PasswordResetSuccess extends PasswordRecoveryState {
  const PasswordResetSuccess({
    required super.email,
  }) : super(currentStep: RecoveryStep.completed);
}

/// Error en cualquier paso
class PasswordRecoveryError extends PasswordRecoveryState {
  final String message;

  const PasswordRecoveryError({
    required this.message,
    required super.email,
    super.code,
    required super.currentStep,
  });

  @override
  List<Object?> get props => [message, email, code, currentStep];
}
