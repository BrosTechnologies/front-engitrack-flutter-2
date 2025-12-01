// lib/features/auth/presentation/bloc/login/login_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Estados posibles del login
enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado del LoginBloc
class LoginState extends Equatable {
  /// Estado actual del proceso de login
  final LoginStatus status;

  /// Email ingresado
  final String email;

  /// Password ingresado
  final String password;

  /// Si el password es visible
  final bool isPasswordVisible;

  /// Mensaje de error (si hay)
  final String? errorMessage;

  /// Usuario autenticado (si el login fue exitoso)
  final User? user;

  /// Error de validación del email
  final String? emailError;

  /// Error de validación del password
  final String? passwordError;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.errorMessage,
    this.user,
    this.emailError,
    this.passwordError,
  });

  /// Verifica si el formulario es válido
  bool get isFormValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  /// Verifica si está cargando
  bool get isLoading => status == LoginStatus.loading;

  /// Crea una copia del estado con los valores modificados
  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isPasswordVisible,
    String? errorMessage,
    User? user,
    String? emailError,
    String? passwordError,
    bool clearError = false,
    bool clearEmailError = false,
    bool clearPasswordError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isPasswordVisible,
        errorMessage,
        user,
        emailError,
        passwordError,
      ];
}
