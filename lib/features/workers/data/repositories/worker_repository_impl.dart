// lib/features/workers/data/repositories/worker_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/worker.dart';
import '../../domain/entities/project_worker.dart';
import '../../domain/entities/worker_assignment.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_remote_datasource.dart';
import '../models/create_worker_request_dto.dart';
import '../models/update_worker_request_dto.dart';
import '../models/assign_worker_request_dto.dart';

/// Implementación del repositorio de workers
class WorkerRepositoryImpl implements WorkerRepository {
  final WorkerRemoteDataSource _remoteDataSource;

  WorkerRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Worker>>> getWorkers() async {
    try {
      final workers = await _remoteDataSource.getWorkers();
      return Right(workers.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Worker>> getWorkerById(String workerId) async {
    try {
      final worker = await _remoteDataSource.getWorkerById(workerId);
      return Right(worker.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Worker>> createWorker(
    CreateWorkerParams params,
  ) async {
    try {
      final request = CreateWorkerRequestDto(
        fullName: params.fullName,
        documentNumber: params.documentNumber,
        phone: params.phone,
        position: params.position,
        hourlyRate: params.hourlyRate,
      );
      final worker = await _remoteDataSource.createWorker(request);
      return Right(worker.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Worker>> updateWorker(
    String workerId,
    UpdateWorkerParams params,
  ) async {
    try {
      final request = UpdateWorkerRequestDto(
        fullName: params.fullName,
        documentNumber: params.documentNumber,
        phone: params.phone,
        position: params.position,
        hourlyRate: params.hourlyRate,
      );
      final worker = await _remoteDataSource.updateWorker(workerId, request);
      return Right(worker.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorker(String workerId) async {
    try {
      await _remoteDataSource.deleteWorker(workerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WorkerAssignment>>> getWorkerAssignments(
    String workerId,
  ) async {
    try {
      final assignments =
          await _remoteDataSource.getWorkerAssignments(workerId);
      return Right(assignments.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProjectWorker>>> getProjectWorkers(
    String projectId,
  ) async {
    try {
      final workers = await _remoteDataSource.getProjectWorkers(projectId);
      return Right(workers.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProjectWorker>> assignWorkerToProject(
    String projectId,
    AssignWorkerParams params,
  ) async {
    try {
      final request = AssignWorkerRequestDto(
        workerId: params.workerId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      final projectWorker =
          await _remoteDataSource.assignWorkerToProject(projectId, request);
      return Right(projectWorker.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeWorkerFromProject(
    String projectId,
    String workerId,
  ) async {
    try {
      await _remoteDataSource.removeWorkerFromProject(projectId, workerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
