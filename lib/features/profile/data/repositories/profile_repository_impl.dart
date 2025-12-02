// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/update_profile_request_dto.dart';

/// Implementación del repositorio de perfil
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserStats>> getStats() async {
    try {
      final stats = await _remoteDataSource.getStats();
      return Right(stats.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
    UpdateProfileParams params,
  ) async {
    try {
      final request = UpdateProfileRequestDto(
        fullName: params.fullName,
        phone: params.phone,
      );
      final profile = await _remoteDataSource.updateProfile(request);
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserById(String userId) async {
    try {
      final profile = await _remoteDataSource.getUserById(userId);
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
