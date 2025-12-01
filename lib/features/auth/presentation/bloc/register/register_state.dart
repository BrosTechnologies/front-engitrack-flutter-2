// lib/features/auth/presentation/bloc/register/register_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Estados posibles del registro
enum RegisterStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado del RegisterBloc
class RegisterState extends Equatable {
  /// Estado actual del proceso de registro
  final RegisterStatus status;

  /// Nombre completo
  final String fullName;

  /// Email
  final String email;

  /// Teléfono
  final String phone;

  /// Password
  final String password;

  /// Confirmación de password
  final String confirmPassword;

  /// Rol seleccionado ("SUPERVISOR" o "CONTRACTOR")
  final String role;

  /// Si el password es visible
  final bool isPasswordVisible;

  /// Si el confirm password es visible
  final bool isConfirmPasswordVisible;

  /// Mensaje de error general
  final String? errorMessage;

  /// Usuario creado (si el registro fue exitoso)
  final User? user;

  // Errores de validación por campo
  final String? fullNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? roleError;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.role = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.errorMessage,
    this.user,
    this.fullNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.confirmPasswordError,
    this.roleError,
  });

  /// Verifica si el formulario es válido
  bool get isFormValid =>
      fullName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      role.isNotEmpty &&
      fullNameError == null &&
      emailError == null &&
      phoneError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      roleError == null;

  /// Verifica si está cargando
  bool get isLoading => status == RegisterStatus.loading;

  /// Crea una copia del estado con los valores modificados
  RegisterState copyWith({
    RegisterStatus? status,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    String? role,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? errorMessage,
    User? user,
    String? fullNameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? confirmPasswordError,
    String? roleError,
    bool clearError = false,
    bool clearFullNameError = false,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool clearRoleError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      role: role ?? this.role,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      fullNameError:
          clearFullNameError ? null : (fullNameError ?? this.fullNameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      roleError: clearRoleError ? null : (roleError ?? this.roleError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        fullName,
        email,
        phone,
        password,
        confirmPassword,
        role,
        isPasswordVisible,
        isConfirmPasswordVisible,
        errorMessage,
        user,
        fullNameError,
        emailError,
        phoneError,
        passwordError,
        confirmPasswordError,
        roleError,
      ];
}
