// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repositorio abstracto de autenticación (domain layer)
/// Define el contrato que debe implementar el repositorio de datos
abstract class AuthRepository {
  /// Inicia sesión con email y password
  /// Retorna `Either<Failure, User>`
  /// - Left: Failure con mensaje de error
  /// - Right: User autenticado con token
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  /// Retorna `Either<Failure, User>`
  /// - Left: Failure con mensaje de error
  /// - Right: User creado y autenticado con token
  Future<Either<Failure, User>> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    required String role,
  });

  /// Cierra la sesión del usuario actual
  /// Limpia todos los datos guardados localmente
  Future<void> logout();

  /// Verifica si hay un usuario logueado
  Future<bool> isLoggedIn();

  /// Obtiene el usuario actual desde el storage local
  /// Retorna null si no hay usuario logueado
  Future<User?> getCurrentUser();
  
  /// Solicita código de recuperación de contraseña
  /// Envía un código de 6 dígitos al email
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });
  
  /// Verifica el código de recuperación
  /// Retorna success si el código es válido
  Future<Either<Failure, void>> verifyResetCode({
    required String email,
    required String code,
  });
  
  /// Restablece la contraseña con el código verificado
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  
  /// Cambia la contraseña del usuario autenticado
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
