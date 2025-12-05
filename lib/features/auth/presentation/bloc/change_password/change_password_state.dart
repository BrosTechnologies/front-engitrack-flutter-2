// lib/features/auth/presentation/bloc/change_password/change_password_state.dart

import 'package:equatable/equatable.dart';

/// Estados del bloc de cambio de contraseña
abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

/// Procesando cambio de contraseña
class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

/// Cambio de contraseña exitoso
class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

/// Error en cambio de contraseña
class ChangePasswordError extends ChangePasswordState {
  final String message;

  const ChangePasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
