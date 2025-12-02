// lib/features/workers/presentation/bloc/worker_assignments/worker_assignments_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de asignaciones de worker
abstract class WorkerAssignmentsEvent extends Equatable {
  const WorkerAssignmentsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar las asignaciones de un worker
class LoadWorkerAssignmentsEvent extends WorkerAssignmentsEvent {
  final String workerId;

  const LoadWorkerAssignmentsEvent(this.workerId);

  @override
  List<Object?> get props => [workerId];
}

/// Evento para refrescar las asignaciones
class RefreshWorkerAssignmentsEvent extends WorkerAssignmentsEvent {
  final String workerId;

  const RefreshWorkerAssignmentsEvent(this.workerId);

  @override
  List<Object?> get props => [workerId];
}
