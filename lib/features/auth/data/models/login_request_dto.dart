// lib/features/auth/data/models/login_request_dto.dart

/// DTO para la petición de login
/// Mapea al body JSON de POST /auth/login
class LoginRequestDto {
  /// Email del usuario
  final String email;

  /// Contraseña del usuario
  final String password;

  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => 'LoginRequestDto(email: $email)';
}
