// lib/features/workers/presentation/bloc/workers_list/workers_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/worker_repository.dart';
import 'workers_list_event.dart';
import 'workers_list_state.dart';

/// Bloc para manejar la lista de workers
class WorkersListBloc extends Bloc<WorkersListEvent, WorkersListState> {
  final WorkerRepository _workerRepository;

  WorkersListBloc(this._workerRepository) : super(const WorkersListInitial()) {
    on<LoadWorkersEvent>(_onLoadWorkers);
    on<RefreshWorkersEvent>(_onRefreshWorkers);
    on<DeleteWorkerEvent>(_onDeleteWorker);
  }

  Future<void> _onLoadWorkers(
    LoadWorkersEvent event,
    Emitter<WorkersListState> emit,
  ) async {
    emit(const WorkersListLoading());

    final result = await _workerRepository.getWorkers();

    result.fold(
      (failure) => emit(WorkersListError(failure.message)),
      (workers) => emit(WorkersListLoaded(workers)),
    );
  }

  Future<void> _onRefreshWorkers(
    RefreshWorkersEvent event,
    Emitter<WorkersListState> emit,
  ) async {
    final result = await _workerRepository.getWorkers();

    result.fold(
      (failure) => emit(WorkersListError(failure.message)),
      (workers) => emit(WorkersListLoaded(workers)),
    );
  }

  Future<void> _onDeleteWorker(
    DeleteWorkerEvent event,
    Emitter<WorkersListState> emit,
  ) async {
    final result = await _workerRepository.deleteWorker(event.workerId);

    await result.fold(
      (failure) async => emit(WorkersListError(failure.message)),
      (_) async {
        emit(const WorkerDeleted('Worker eliminado correctamente'));
        // Recargar la lista después de eliminar
        add(const RefreshWorkersEvent());
      },
    );
  }
}
