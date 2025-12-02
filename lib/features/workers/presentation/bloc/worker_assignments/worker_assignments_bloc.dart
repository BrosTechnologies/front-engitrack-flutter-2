// lib/features/workers/presentation/bloc/worker_assignments/worker_assignments_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/worker_repository.dart';
import 'worker_assignments_event.dart';
import 'worker_assignments_state.dart';

/// Bloc para manejar las asignaciones de un worker
class WorkerAssignmentsBloc
    extends Bloc<WorkerAssignmentsEvent, WorkerAssignmentsState> {
  final WorkerRepository _workerRepository;

  WorkerAssignmentsBloc(this._workerRepository)
      : super(const WorkerAssignmentsInitial()) {
    on<LoadWorkerAssignmentsEvent>(_onLoadAssignments);
    on<RefreshWorkerAssignmentsEvent>(_onRefreshAssignments);
  }

  Future<void> _onLoadAssignments(
    LoadWorkerAssignmentsEvent event,
    Emitter<WorkerAssignmentsState> emit,
  ) async {
    emit(const WorkerAssignmentsLoading());

    final result =
        await _workerRepository.getWorkerAssignments(event.workerId);

    result.fold(
      (failure) => emit(WorkerAssignmentsError(failure.message)),
      (assignments) =>
          emit(WorkerAssignmentsLoaded.fromAssignments(assignments)),
    );
  }

  Future<void> _onRefreshAssignments(
    RefreshWorkerAssignmentsEvent event,
    Emitter<WorkerAssignmentsState> emit,
  ) async {
    final result =
        await _workerRepository.getWorkerAssignments(event.workerId);

    result.fold(
      (failure) => emit(WorkerAssignmentsError(failure.message)),
      (assignments) =>
          emit(WorkerAssignmentsLoaded.fromAssignments(assignments)),
    );
  }
}
