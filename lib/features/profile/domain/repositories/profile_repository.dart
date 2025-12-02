// lib/features/profile/domain/repositories/profile_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../entities/user_stats.dart';

/// Parámetros para actualizar el perfil
class UpdateProfileParams {
  final String fullName;
  final String? phone;

  const UpdateProfileParams({
    required this.fullName,
    this.phone,
  });
}

/// Repositorio abstracto para operaciones de perfil
abstract class ProfileRepository {
  /// Obtiene el perfil del usuario autenticado
  Future<Either<Failure, UserProfile>> getProfile();

  /// Obtiene las estadísticas del usuario
  Future<Either<Failure, UserStats>> getStats();

  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserProfile>> updateProfile(UpdateProfileParams params);

  /// Obtiene un usuario por ID
  Future<Either<Failure, UserProfile>> getUserById(String userId);
}
