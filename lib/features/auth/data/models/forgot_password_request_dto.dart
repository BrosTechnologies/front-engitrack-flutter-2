// lib/features/auth/data/models/forgot_password_request_dto.dart

/// DTO para solicitar código de recuperación de contraseña
/// Mapea al body JSON de POST /auth/forgot-password
class ForgotPasswordRequestDto {
  /// Email del usuario
  final String email;

  const ForgotPasswordRequestDto({
    required this.email,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  String toString() => 'ForgotPasswordRequestDto(email: $email)';
}
