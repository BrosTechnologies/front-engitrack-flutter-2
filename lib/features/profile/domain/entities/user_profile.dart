// lib/features/profile/domain/entities/user_profile.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa el perfil del usuario
class UserProfile extends Equatable {
  /// ID único del usuario
  final String id;

  /// Email del usuario
  final String email;

  /// Nombre completo del usuario
  final String fullName;

  /// Teléfono del usuario
  final String phone;

  /// Rol del usuario (ej: "USER", "ADMIN")
  final String role;

  /// ID del worker asociado (si tiene perfil de colaborador)
  final String? workerId;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.role = 'USER',
    this.workerId,
  });

  /// Obtiene las iniciales del nombre
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Verifica si el usuario tiene perfil de colaborador
  bool get hasWorkerProfile => workerId != null && workerId!.isNotEmpty;

  /// Obtiene el rol formateado para mostrar
  String get formattedRole {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'USER':
        return 'Usuario';
      case 'MANAGER':
        return 'Gerente';
      default:
        return role;
    }
  }

  /// Copia la entidad con valores modificados
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    String? workerId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      workerId: workerId ?? this.workerId,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, phone, role, workerId];
}
