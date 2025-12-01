// lib/features/auth/presentation/bloc/register/register_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Bloc para manejar la lógica de registro
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc(this._authRepository) : super(const RegisterState()) {
    on<RegisterFullNameChanged>(_onFullNameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterRoleChanged>(_onRoleChanged);
    on<RegisterTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<RegisterToggleConfirmPasswordVisibility>(
        _onToggleConfirmPasswordVisibility);
    on<RegisterSubmitted>(_onSubmitted);
  }

  /// Maneja cambios en el nombre completo
  void _onFullNameChanged(
    RegisterFullNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      fullName: event.fullName,
      clearFullNameError: true,
      clearError: true,
    ));
  }

  /// Maneja cambios en el email
  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    final email = event.email;
    String? emailError;

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

  /// Maneja cambios en el teléfono
  void _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      clearPhoneError: true,
      clearError: true,
    ));
  }

  /// Maneja cambios en el password
  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final password = event.password;
    String? passwordError;
    String? confirmPasswordError;

    if (password.isNotEmpty && password.length < 6) {
      passwordError = 'Mínimo 6 caracteres';
    }

    // Revalidar confirm password si ya tiene valor
    if (state.confirmPassword.isNotEmpty &&
        state.confirmPassword != password) {
      confirmPasswordError = 'Las contraseñas no coinciden';
    }

    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      clearPasswordError: passwordError == null,
      clearConfirmPasswordError: confirmPasswordError == null,
      clearError: true,
    ));
  }

  /// Maneja cambios en la confirmación de password
  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final confirmPassword = event.confirmPassword;
    String? confirmPasswordError;

    if (confirmPassword.isNotEmpty && confirmPassword != state.password) {
      confirmPasswordError = 'Las contraseñas no coinciden';
    }

    emit(state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: confirmPasswordError,
      clearConfirmPasswordError: confirmPasswordError == null,
      clearError: true,
    ));
  }

  /// Maneja cambios en el rol
  void _onRoleChanged(
    RegisterRoleChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      role: event.role,
      clearRoleError: true,
      clearError: true,
    ));
  }

  /// Alterna la visibilidad del password
  void _onTogglePasswordVisibility(
    RegisterTogglePasswordVisibility event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  /// Alterna la visibilidad del confirm password
  void _onToggleConfirmPasswordVisibility(
    RegisterToggleConfirmPasswordVisibility event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    ));
  }

  /// Maneja el envío del formulario
  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    // Validar campos
    if (!_validateForm(emit)) return;

    // Iniciar loading
    emit(state.copyWith(
      status: RegisterStatus.loading,
      clearError: true,
    ));

    // Llamar al repositorio
    final result = await _authRepository.register(
      email: state.email.trim(),
      fullName: state.fullName.trim(),
      phone: state.phone.trim(),
      password: state.password,
      role: state.role,
    );

    // Procesar resultado
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (user) {
        emit(state.copyWith(
          status: RegisterStatus.success,
          user: user,
        ));
      },
    );
  }

  /// Valida el formulario antes de enviar
  bool _validateForm(Emitter<RegisterState> emit) {
    String? fullNameError;
    String? emailError;
    String? phoneError;
    String? passwordError;
    String? confirmPasswordError;
    String? roleError;

    if (state.fullName.isEmpty) {
      fullNameError = 'El nombre es requerido';
    }

    if (state.email.isEmpty) {
      emailError = 'El email es requerido';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Ingresa un email válido';
    }

    if (state.phone.isEmpty) {
      phoneError = 'El teléfono es requerido';
    }

    if (state.password.isEmpty) {
      passwordError = 'La contraseña es requerida';
    } else if (state.password.length < 6) {
      passwordError = 'Mínimo 6 caracteres';
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirma tu contraseña';
    } else if (state.confirmPassword != state.password) {
      confirmPasswordError = 'Las contraseñas no coinciden';
    }

    if (state.role.isEmpty) {
      roleError = 'Selecciona un rol';
    }

    if (fullNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        roleError != null) {
      emit(state.copyWith(
        fullNameError: fullNameError,
        emailError: emailError,
        phoneError: phoneError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        roleError: roleError,
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
