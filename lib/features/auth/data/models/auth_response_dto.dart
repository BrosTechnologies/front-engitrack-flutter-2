// lib/features/auth/data/models/auth_response_dto.dart

import '../../domain/entities/user.dart';

/// DTO para la respuesta de autenticación de la API
/// Mapea el JSON de /auth/login y /auth/register
class AuthResponseDto {
  /// ID del usuario (UUID)
  final String userId;

  /// Email del usuario
  final String email;

  /// Rol del usuario
  final String role;

  /// Token JWT de acceso
  final String accessToken;

  const AuthResponseDto({
    required this.userId,
    required this.email,
    required this.role,
    required this.accessToken,
  });

  /// Crea una instancia desde JSON de la API
  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  /// Convierte el DTO a la entidad de dominio
  User toEntity({String? fullName}) {
    return User(
      id: userId,
      email: email,
      role: role,
      token: accessToken,
      fullName: fullName,
    );
  }

  /// Convierte a Map para debug o logging
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'role': role,
      'accessToken': accessToken,
    };
  }

  @override
  String toString() =>
      'AuthResponseDto(userId: $userId, email: $email, role: $role)';
}
