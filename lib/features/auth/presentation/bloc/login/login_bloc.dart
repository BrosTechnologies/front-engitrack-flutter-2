// lib/features/auth/presentation/bloc/login/login_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Bloc para manejar la lógica de login
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<LoginSubmitted>(_onSubmitted);
  }

  /// Maneja cambios en el email
  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    final email = event.email;
    String? emailError;

    // Validar email solo si no está vacío
    if (email.isNotEmpty && !_isValidEmail(email)) {
      emailError = 'Ingresa un email válido';
    }

    emit(state.copyWith(
      email: email,
      emailError: emailError,
      clearEmailError: emailError == null,
      clearError: true,
    ));
  }

  /// Maneja cambios en el password
  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      password: event.password,
      clearPasswordError: true,
      clearError: true,
    ));
  }

  /// Alterna la visibilidad del password
  void _onTogglePasswordVisibility(
    LoginTogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  /// Maneja el envío del formulario
  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Validar campos
    if (!_validateForm(emit)) return;

    // Iniciar loading
    emit(state.copyWith(
      status: LoginStatus.loading,
      clearError: true,
    ));

    // Llamar al repositorio
    final result = await _authRepository.login(
      email: state.email.trim(),
      password: state.password,
    );

    // Procesar resultado
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (user) {
        emit(state.copyWith(
          status: LoginStatus.success,
          user: user,
        ));
      },
    );
  }

  /// Valida el formulario antes de enviar
  bool _validateForm(Emitter<LoginState> emit) {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty) {
      emailError = 'El email es requerido';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Ingresa un email válido';
    }

    if (state.password.isEmpty) {
      passwordError = 'La contraseña es requerida';
    }

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return false;
    }

    return true;
  }

  /// Valida el formato del email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
