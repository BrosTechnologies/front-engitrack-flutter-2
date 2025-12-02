// lib/features/workers/presentation/bloc/workers_list/workers_list_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de lista de workers
abstract class WorkersListEvent extends Equatable {
  const WorkersListEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de workers
class LoadWorkersEvent extends WorkersListEvent {
  const LoadWorkersEvent();
}

/// Evento para refrescar la lista de workers
class RefreshWorkersEvent extends WorkersListEvent {
  const RefreshWorkersEvent();
}

/// Evento para eliminar un worker
class DeleteWorkerEvent extends WorkersListEvent {
  final String workerId;

  const DeleteWorkerEvent(this.workerId);

  @override
  List<Object?> get props => [workerId];
}
