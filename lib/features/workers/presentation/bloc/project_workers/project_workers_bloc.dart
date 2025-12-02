// lib/features/workers/presentation/bloc/project_workers/project_workers_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/worker_repository.dart';
import 'project_workers_event.dart';
import 'project_workers_state.dart';

/// Bloc para manejar los workers de un proyecto
class ProjectWorkersBloc
    extends Bloc<ProjectWorkersEvent, ProjectWorkersState> {
  final WorkerRepository _workerRepository;

  ProjectWorkersBloc(this._workerRepository)
      : super(const ProjectWorkersInitial()) {
    on<LoadProjectWorkersEvent>(_onLoadProjectWorkers);
    on<RefreshProjectWorkersEvent>(_onRefreshProjectWorkers);
    on<AssignWorkerEvent>(_onAssignWorker);
    on<RemoveWorkerFromProjectEvent>(_onRemoveWorker);
  }

  Future<void> _onLoadProjectWorkers(
    LoadProjectWorkersEvent event,
    Emitter<ProjectWorkersState> emit,
  ) async {
    emit(const ProjectWorkersLoading());

    final result = await _workerRepository.getProjectWorkers(event.projectId);

    result.fold(
      (failure) => emit(ProjectWorkersError(failure.message)),
      (workers) => emit(ProjectWorkersLoaded.fromWorkers(workers)),
    );
  }

  Future<void> _onRefreshProjectWorkers(
    RefreshProjectWorkersEvent event,
    Emitter<ProjectWorkersState> emit,
  ) async {
    final result = await _workerRepository.getProjectWorkers(event.projectId);

    result.fold(
      (failure) => emit(ProjectWorkersError(failure.message)),
      (workers) => emit(ProjectWorkersLoaded.fromWorkers(workers)),
    );
  }

  Future<void> _onAssignWorker(
    AssignWorkerEvent event,
    Emitter<ProjectWorkersState> emit,
  ) async {
    emit(const ProjectWorkersLoading());

    final result = await _workerRepository.assignWorkerToProject(
      event.projectId,
      AssignWorkerParams(
        workerId: event.workerId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    await result.fold(
      (failure) async => emit(ProjectWorkersError(failure.message)),
      (worker) async {
        emit(WorkerAssigned(
          worker: worker,
          message: 'Worker asignado correctamente',
        ));
        // Recargar la lista después de asignar
        add(RefreshProjectWorkersEvent(event.projectId));
      },
    );
  }

  Future<void> _onRemoveWorker(
    RemoveWorkerFromProjectEvent event,
    Emitter<ProjectWorkersState> emit,
  ) async {
    final result = await _workerRepository.removeWorkerFromProject(
      event.projectId,
      event.workerId,
    );

    await result.fold(
      (failure) async => emit(ProjectWorkersError(failure.message)),
      (_) async {
        emit(const WorkerRemoved('Worker removido del proyecto'));
        // Recargar la lista después de remover
        add(RefreshProjectWorkersEvent(event.projectId));
      },
    );
  }
}
