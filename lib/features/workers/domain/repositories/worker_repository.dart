// lib/features/workers/domain/repositories/worker_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/worker.dart';
import '../entities/project_worker.dart';
import '../entities/worker_assignment.dart';

/// Parámetros para crear un worker
class CreateWorkerParams {
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;

  const CreateWorkerParams({
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
  });
}

/// Parámetros para actualizar un worker
class UpdateWorkerParams {
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;

  const UpdateWorkerParams({
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
  });
}

/// Parámetros para asignar un worker a un proyecto
class AssignWorkerParams {
  final String workerId;
  final DateTime startDate;
  final DateTime? endDate;

  const AssignWorkerParams({
    required this.workerId,
    required this.startDate,
    this.endDate,
  });
}

/// Repositorio abstracto para operaciones con workers
abstract class WorkerRepository {
  // ============ WORKERS CRUD ============

  /// Obtiene lista de todos los workers
  Future<Either<Failure, List<Worker>>> getWorkers();

  /// Obtiene un worker por su ID
  Future<Either<Failure, Worker>> getWorkerById(String workerId);

  /// Crea un nuevo worker
  Future<Either<Failure, Worker>> createWorker(CreateWorkerParams params);

  /// Actualiza un worker existente
  Future<Either<Failure, Worker>> updateWorker(
    String workerId,
    UpdateWorkerParams params,
  );

  /// Elimina un worker
  Future<Either<Failure, void>> deleteWorker(String workerId);

  // ============ WORKER ASSIGNMENTS ============

  /// Obtiene las asignaciones de un worker específico
  Future<Either<Failure, List<WorkerAssignment>>> getWorkerAssignments(
    String workerId,
  );

  // ============ PROJECT WORKERS ============

  /// Obtiene los workers asignados a un proyecto
  Future<Either<Failure, List<ProjectWorker>>> getProjectWorkers(
    String projectId,
  );

  /// Asigna un worker a un proyecto
  Future<Either<Failure, ProjectWorker>> assignWorkerToProject(
    String projectId,
    AssignWorkerParams params,
  );

  /// Remueve un worker de un proyecto
  Future<Either<Failure, void>> removeWorkerFromProject(
    String projectId,
    String workerId,
  );
}
