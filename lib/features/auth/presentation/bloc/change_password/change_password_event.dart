// lib/features/auth/presentation/bloc/change_password/change_password_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de cambio de contraseña
abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Solicitar cambio de contraseña
class ChangePasswordSubmit extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordSubmit({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Reiniciar estado
class ResetChangePasswordState extends ChangePasswordEvent {
  const ResetChangePasswordState();
}
