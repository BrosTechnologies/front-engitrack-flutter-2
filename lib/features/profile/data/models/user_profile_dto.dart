// lib/features/profile/data/models/user_profile_dto.dart

import '../../domain/entities/user_profile.dart';

/// DTO para UserProfile
class UserProfileDto {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String? workerId;

  UserProfileDto({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.role = 'USER',
    this.workerId,
  });

  /// Crea DTO desde JSON del servidor
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      workerId: json['workerId'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      if (workerId != null) 'workerId': workerId,
    };
  }

  /// Convierte a entidad de dominio
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      role: role,
      workerId: workerId,
    );
  }

  /// Crea DTO desde entidad
  factory UserProfileDto.fromEntity(UserProfile entity) {
    return UserProfileDto(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phone: entity.phone,
      role: entity.role,
      workerId: entity.workerId,
    );
  }
}
