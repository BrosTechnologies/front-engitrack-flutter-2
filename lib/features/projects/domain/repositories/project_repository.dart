// lib/features/projects/domain/repositories/project_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project.dart';
import '../entities/task.dart' as domain;
import '../enums/project_status.dart';
import '../enums/task_status.dart';
import '../enums/priority.dart';

/// Interfaz del repositorio de proyectos
/// Define las operaciones disponibles para gestionar proyectos y tareas
abstract class ProjectRepository {
  // ============ PROJECTS ============

  /// Obtiene lista de proyectos con filtros opcionales
  Future<Either<Failure, List<Project>>> getProjects({
    ProjectStatus? status,
    String? searchQuery,
    int? page,
    int? pageSize,
  });

  /// Obtiene un proyecto por su ID
  Future<Either<Failure, Project>> getProjectById(String projectId);

  /// Crea un nuevo proyecto
  Future<Either<Failure, Project>> createProject({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    required Priority priority,
    required String ownerUserId,
    List<CreateTaskParams>? initialTasks,
  });

  /// Actualiza un proyecto existente
  Future<Either<Failure, Project>> updateProject({
    required String projectId,
    String? name,
    String? description,
    double? budget,
    DateTime? endDate,
    Priority? priority,
  });

  /// Elimina un proyecto
  Future<Either<Failure, void>> deleteProject(String projectId);

  /// Marca un proyecto como completado
  Future<Either<Failure, Project>> completeProject(String projectId);

  // ============ TASKS ============

  /// Crea una nueva tarea en un proyecto
  Future<Either<Failure, domain.Task>> createTask({
    required String projectId,
    required String title,
    DateTime? dueDate,
  });

  /// Actualiza el estado de una tarea
  Future<Either<Failure, domain.Task>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus status,
  });

  /// Elimina una tarea de un proyecto
  Future<Either<Failure, void>> deleteTask({
    required String projectId,
    required String taskId,
  });
}

/// Parámetros para crear una tarea inicial en un proyecto
class CreateTaskParams {
  final String title;
  final DateTime? dueDate;

  const CreateTaskParams({
    required this.title,
    this.dueDate,
  });
}
