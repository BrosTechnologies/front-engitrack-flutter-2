// lib/features/auth/presentation/bloc/password_recovery/password_recovery_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de recuperación de contraseña
abstract class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Solicitar código de recuperación
class RequestResetCode extends PasswordRecoveryEvent {
  final String email;

  const RequestResetCode(this.email);

  @override
  List<Object?> get props => [email];
}

/// Verificar código de recuperación
class VerifyCode extends PasswordRecoveryEvent {
  final String code;

  const VerifyCode(this.code);

  @override
  List<Object?> get props => [code];
}

/// Restablecer contraseña
class ResetPasswordSubmit extends PasswordRecoveryEvent {
  final String newPassword;

  const ResetPasswordSubmit(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

/// Reenviar código de recuperación
class ResendCode extends PasswordRecoveryEvent {
  const ResendCode();
}

/// Reiniciar el proceso de recuperación
class ResetRecoveryProcess extends PasswordRecoveryEvent {
  const ResetRecoveryProcess();
}
