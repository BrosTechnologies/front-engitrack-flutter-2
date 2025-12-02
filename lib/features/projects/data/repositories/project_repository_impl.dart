// lib/features/projects/data/repositories/project_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart' as domain;
import '../../domain/enums/priority.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/create_project_request_dto.dart';
import '../models/create_task_request_dto.dart';
import '../models/update_project_request_dto.dart';
import '../models/update_task_status_request_dto.dart';

/// Implementación del repositorio de proyectos
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Project>>> getProjects({
    ProjectStatus? status,
    String? searchQuery,
    int? page,
    int? pageSize,
  }) async {
    try {
      final projectDtos = await _remoteDataSource.getProjects(
        status: status?.toApiString(),
        searchQuery: searchQuery,
        page: page,
        pageSize: pageSize,
      );

      final projects = projectDtos.map((dto) => dto.toEntity()).toList();
      return Right(projects);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String projectId) async {
    try {
      final projectDto = await _remoteDataSource.getProjectById(projectId);
      return Right(projectDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    required Priority priority,
    required String ownerUserId,
    List<CreateTaskParams>? initialTasks,
  }) async {
    try {
      final request = CreateProjectRequestDto.create(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        priority: priority,
        ownerUserId: ownerUserId,
        tasks: initialTasks
            ?.map((t) => CreateTaskRequestDto.create(
                  title: t.title,
                  dueDate: t.dueDate,
                ))
            .toList(),
      );

      final projectDto = await _remoteDataSource.createProject(request);
      return Right(projectDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject({
    required String projectId,
    String? name,
    String? description,
    double? budget,
    DateTime? endDate,
    Priority? priority,
  }) async {
    try {
      final request = UpdateProjectRequestDto.create(
        name: name,
        description: description,
        budget: budget,
        endDate: endDate,
        priority: priority,
      );

      final projectDto = await _remoteDataSource.updateProject(
        projectId,
        request,
      );
      return Right(projectDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      await _remoteDataSource.deleteProject(projectId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Project>> completeProject(String projectId) async {
    try {
      final projectDto = await _remoteDataSource.completeProject(projectId);
      return Right(projectDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Task>> createTask({
    required String projectId,
    required String title,
    DateTime? dueDate,
  }) async {
    try {
      final request = CreateTaskRequestDto.create(
        title: title,
        dueDate: dueDate,
      );

      final taskDto = await _remoteDataSource.createTask(projectId, request);
      return Right(taskDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Task>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus status,
  }) async {
    try {
      final request = UpdateTaskStatusRequestDto.fromStatus(status);

      final taskDto = await _remoteDataSource.updateTaskStatus(
        projectId,
        taskId,
        request,
      );
      return Right(taskDto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    try {
      await _remoteDataSource.deleteTask(projectId, taskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
