// lib/features/auth/data/models/reset_password_request_dto.dart

/// DTO para restablecer contraseña con código
/// Mapea al body JSON de POST /auth/reset-password
class ResetPasswordRequestDto {
  /// Email del usuario
  final String email;

  /// Código de 6 dígitos verificado
  final String code;

  /// Nueva contraseña
  final String newPassword;

  const ResetPasswordRequestDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    };
  }

  @override
  String toString() => 'ResetPasswordRequestDto(email: $email, code: $code)';
}
