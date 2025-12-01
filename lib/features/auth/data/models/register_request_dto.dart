// lib/features/auth/data/models/register_request_dto.dart

/// DTO para la petición de registro
/// Mapea al body JSON de POST /auth/register
class RegisterRequestDto {
  /// Email del usuario
  final String email;

  /// Nombre completo del usuario
  final String fullName;

  /// Teléfono del usuario
  final String phone;

  /// Contraseña del usuario
  final String password;

  /// Rol del usuario: "SUPERVISOR" o "CONTRACTOR"
  final String role;

  const RegisterRequestDto({
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.role,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'role': role,
    };
  }

  @override
  String toString() =>
      'RegisterRequestDto(email: $email, fullName: $fullName, role: $role)';
}
