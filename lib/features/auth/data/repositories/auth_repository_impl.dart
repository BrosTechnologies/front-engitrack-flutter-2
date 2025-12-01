// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';

/// Implementación del repositorio de autenticación
/// Conecta el datasource remoto con el domain layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthManager _authManager;

  AuthRepositoryImpl(this._remoteDataSource, this._authManager);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Crear DTO de request
      final request = LoginRequestDto(
        email: email,
        password: password,
      );

      // Llamar al datasource
      final response = await _remoteDataSource.login(request);

      // Convertir a entidad
      final user = response.toEntity();

      // Guardar datos en AuthManager
      await _saveUserData(user);

      return Right(user);
    } on AuthException catch (e) {
      if (e.statusCode == 401) {
        return Left(AuthFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // Crear DTO de request
      final request = RegisterRequestDto(
        email: email,
        fullName: fullName,
        phone: phone,
        password: password,
        role: role,
      );

      // Llamar al datasource
      final response = await _remoteDataSource.register(request);

      // Convertir a entidad (incluir fullName que viene del request)
      final user = response.toEntity(fullName: fullName);

      // Guardar datos en AuthManager
      await _saveUserData(user);

      return Right(user);
    } on AuthException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 422) {
        return Left(ValidationFailure(e.message));
      }
      if (e.statusCode == 409) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<void> logout() async {
    await _authManager.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _authManager.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    final isLogged = await _authManager.isLoggedIn();
    if (!isLogged) return null;

    final token = await _authManager.getToken();
    final userId = await _authManager.getUserId();
    final email = await _authManager.getUserEmail();
    final role = await _authManager.getUserRole();
    final fullName = await _authManager.getUserFullName();

    if (token == null || userId == null || email == null || role == null) {
      return null;
    }

    return User(
      id: userId,
      email: email,
      role: role,
      token: token,
      fullName: fullName,
    );
  }

  /// Guarda los datos del usuario en AuthManager
  Future<void> _saveUserData(User user) async {
    await _authManager.saveToken(user.token);
    await _authManager.saveUserData(
      userId: user.id,
      email: user.email,
      role: user.role,
      fullName: user.fullName ?? '',
    );
  }
}
