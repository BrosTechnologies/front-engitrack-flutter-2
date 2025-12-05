// lib/features/auth/data/models/verify_reset_code_request_dto.dart

/// DTO para verificar código de recuperación
/// Mapea al body JSON de POST /auth/verify-reset-code
class VerifyResetCodeRequestDto {
  /// Email del usuario
  final String email;

  /// Código de 6 dígitos enviado al email
  final String code;

  const VerifyResetCodeRequestDto({
    required this.email,
    required this.code,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }

  @override
  String toString() => 'VerifyResetCodeRequestDto(email: $email, code: $code)';
}
