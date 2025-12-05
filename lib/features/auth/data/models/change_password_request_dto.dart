// lib/features/auth/data/models/change_password_request_dto.dart

/// DTO para cambiar contraseña de usuario autenticado
/// Mapea al body JSON de POST /api/users/change-password
class ChangePasswordRequestDto {
  /// Contraseña actual
  final String currentPassword;

  /// Nueva contraseña
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  /// Convierte a Map para enviar en el body de la petición
  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }

  @override
  String toString() => 'ChangePasswordRequestDto()';
}
