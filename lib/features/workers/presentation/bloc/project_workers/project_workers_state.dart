// lib/features/workers/presentation/bloc/project_workers/project_workers_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_worker.dart';

/// Estados del bloc de workers de un proyecto
abstract class ProjectWorkersState extends Equatable {
  const ProjectWorkersState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectWorkersInitial extends ProjectWorkersState {
  const ProjectWorkersInitial();
}

/// Estado de carga
class ProjectWorkersLoading extends ProjectWorkersState {
  const ProjectWorkersLoading();
}

/// Estado con datos cargados
class ProjectWorkersLoaded extends ProjectWorkersState {
  final List<ProjectWorker> workers;
  final List<ProjectWorker> activeWorkers;
  final List<ProjectWorker> completedWorkers;

  const ProjectWorkersLoaded({
    required this.workers,
    required this.activeWorkers,
    required this.completedWorkers,
  });

  factory ProjectWorkersLoaded.fromWorkers(List<ProjectWorker> workers) {
    final active = workers.where((w) => w.isActive).toList();
    final completed = workers.where((w) => w.isCompleted).toList();

    return ProjectWorkersLoaded(
      workers: workers,
      activeWorkers: active,
      completedWorkers: completed,
    );
  }

  @override
  List<Object?> get props => [workers, activeWorkers, completedWorkers];
}

/// Estado de error
class ProjectWorkersError extends ProjectWorkersState {
  final String message;

  const ProjectWorkersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado después de asignar un worker
class WorkerAssigned extends ProjectWorkersState {
  final ProjectWorker worker;
  final String message;

  const WorkerAssigned({
    required this.worker,
    required this.message,
  });

  @override
  List<Object?> get props => [worker, message];
}

/// Estado después de remover un worker
class WorkerRemoved extends ProjectWorkersState {
  final String message;

  const WorkerRemoved(this.message);

  @override
  List<Object?> get props => [message];
}
