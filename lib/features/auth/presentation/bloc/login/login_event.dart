// lib/features/auth/presentation/bloc/login/login_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del LoginBloc
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Evento cuando cambia el email
class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Evento cuando cambia el password
class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Evento para alternar visibilidad del password
class LoginTogglePasswordVisibility extends LoginEvent {
  const LoginTogglePasswordVisibility();
}

/// Evento para enviar el formulario de login
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
