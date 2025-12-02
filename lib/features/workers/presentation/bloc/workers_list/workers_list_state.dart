// lib/features/workers/presentation/bloc/workers_list/workers_list_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/worker.dart';

/// Estados del bloc de lista de workers
abstract class WorkersListState extends Equatable {
  const WorkersListState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkersListInitial extends WorkersListState {
  const WorkersListInitial();
}

/// Estado de carga
class WorkersListLoading extends WorkersListState {
  const WorkersListLoading();
}

/// Estado con datos cargados
class WorkersListLoaded extends WorkersListState {
  final List<Worker> workers;

  const WorkersListLoaded(this.workers);

  @override
  List<Object?> get props => [workers];
}

/// Estado de error
class WorkersListError extends WorkersListState {
  final String message;

  const WorkersListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado después de eliminar un worker
class WorkerDeleted extends WorkersListState {
  final String message;

  const WorkerDeleted(this.message);

  @override
  List<Object?> get props => [message];
}
