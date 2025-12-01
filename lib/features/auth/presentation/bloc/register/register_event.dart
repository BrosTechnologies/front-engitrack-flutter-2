// lib/features/auth/presentation/bloc/register/register_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del RegisterBloc
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Evento cuando cambia el nombre completo
class RegisterFullNameChanged extends RegisterEvent {
  final String fullName;

  const RegisterFullNameChanged(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

/// Evento cuando cambia el email
class RegisterEmailChanged extends RegisterEvent {
  final String email;

  const RegisterEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Evento cuando cambia el teléfono
class RegisterPhoneChanged extends RegisterEvent {
  final String phone;

  const RegisterPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Evento cuando cambia el password
class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  const RegisterPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Evento cuando cambia la confirmación de password
class RegisterConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;

  const RegisterConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

/// Evento cuando cambia el rol seleccionado
class RegisterRoleChanged extends RegisterEvent {
  final String role;

  const RegisterRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

/// Evento para alternar visibilidad del password
class RegisterTogglePasswordVisibility extends RegisterEvent {
  const RegisterTogglePasswordVisibility();
}

/// Evento para alternar visibilidad del confirm password
class RegisterToggleConfirmPasswordVisibility extends RegisterEvent {
  const RegisterToggleConfirmPasswordVisibility();
}

/// Evento para enviar el formulario de registro
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}
