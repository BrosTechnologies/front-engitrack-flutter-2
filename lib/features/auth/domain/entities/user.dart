// lib/features/auth/domain/entities/user.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un usuario autenticado
/// Esta es la clase que se usa en toda la aplicación (domain layer)
class User extends Equatable {
  /// ID único del usuario (UUID)
  final String id;

  /// Email del usuario
  final String email;

  /// Rol del usuario: "SUPERVISOR", "CONTRACTOR", "USERS"
  final String role;

  /// Token JWT de acceso
  final String token;

  /// Nombre completo del usuario (opcional, solo disponible en algunos contextos)
  final String? fullName;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    this.fullName,
  });

  /// Verifica si el usuario es Supervisor
  bool get isSupervisor => role == 'SUPERVISOR';

  /// Verifica si el usuario es Contratista
  bool get isContractor => role == 'CONTRACTOR';

  /// Verifica si el usuario es un usuario común
  bool get isUser => role == 'USERS';

  /// Obtiene el nombre para mostrar del rol
  String get roleDisplayName {
    switch (role) {
      case 'SUPERVISOR':
        return 'Supervisor';
      case 'CONTRACTOR':
        return 'Contratista';
      case 'USERS':
        return 'Usuario';
      default:
        return role;
    }
  }

  @override
  List<Object?> get props => [id, email, role, token, fullName];

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';
}
