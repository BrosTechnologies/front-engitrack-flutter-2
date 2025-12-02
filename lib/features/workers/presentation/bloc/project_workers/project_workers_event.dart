// lib/features/workers/presentation/bloc/project_workers/project_workers_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de workers de un proyecto
abstract class ProjectWorkersEvent extends Equatable {
  const ProjectWorkersEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los workers de un proyecto
class LoadProjectWorkersEvent extends ProjectWorkersEvent {
  final String projectId;

  const LoadProjectWorkersEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Evento para refrescar los workers del proyecto
class RefreshProjectWorkersEvent extends ProjectWorkersEvent {
  final String projectId;

  const RefreshProjectWorkersEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Evento para asignar un worker al proyecto
class AssignWorkerEvent extends ProjectWorkersEvent {
  final String projectId;
  final String workerId;
  final DateTime startDate;
  final DateTime? endDate;

  const AssignWorkerEvent({
    required this.projectId,
    required this.workerId,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [projectId, workerId, startDate, endDate];
}

/// Evento para remover un worker del proyecto
class RemoveWorkerFromProjectEvent extends ProjectWorkersEvent {
  final String projectId;
  final String workerId;

  const RemoveWorkerFromProjectEvent({
    required this.projectId,
    required this.workerId,
  });

  @override
  List<Object?> get props => [projectId, workerId];
}
