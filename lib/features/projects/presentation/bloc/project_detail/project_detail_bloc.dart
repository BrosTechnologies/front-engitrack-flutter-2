// lib/features/projects/presentation/bloc/project_detail/project_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/project_repository.dart';
import 'project_detail_event.dart';
import 'project_detail_state.dart';

/// Bloc para gestionar el detalle de un proyecto
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final ProjectRepository _projectRepository;
  String? _currentProjectId;

  ProjectDetailBloc(this._projectRepository)
      : super(const ProjectDetailInitial()) {
    on<LoadProject>(_onLoadProject);
    on<RefreshProject>(_onRefreshProject);
    on<AddTask>(_onAddTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<DeleteTask>(_onDeleteTask);
    on<CompleteProject>(_onCompleteProject);
    on<DeleteProject>(_onDeleteProject);
    on<ClearOperationMessage>(_onClearOperationMessage);
  }

  /// Cargar proyecto por ID
  Future<void> _onLoadProject(
    LoadProject event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(const ProjectDetailLoading());
    _currentProjectId = event.projectId;

    final result = await _projectRepository.getProjectById(event.projectId);

    result.fold(
      (failure) => emit(ProjectDetailError(failure.message)),
      (project) => emit(ProjectDetailLoaded(project: project)),
    );
  }

  /// Refrescar proyecto
  Future<void> _onRefreshProject(
    RefreshProject event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is ProjectDetailLoaded) {
      emit(currentState.copyWith(isProcessing: true));
    }

    final result = await _projectRepository.getProjectById(_currentProjectId!);

    result.fold(
      (failure) {
        if (currentState is ProjectDetailLoaded) {
          emit(currentState.copyWith(
            isProcessing: false,
            operationMessage: failure.message,
            isOperationSuccess: false,
          ));
        } else {
          emit(ProjectDetailError(failure.message));
        }
      },
      (project) => emit(ProjectDetailLoaded(project: project)),
    );
  }

  /// Agregar tarea
  Future<void> _onAddTask(
    AddTask event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true, clearMessage: true));

    final result = await _projectRepository.createTask(
      projectId: _currentProjectId!,
      title: event.title,
      dueDate: event.dueDate,
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(
          isProcessing: false,
          operationMessage: failure.message,
          isOperationSuccess: false,
        ));
      },
      (task) async {
        // Recargar proyecto para obtener lista actualizada
        final projectResult =
            await _projectRepository.getProjectById(_currentProjectId!);
        projectResult.fold(
          (failure) => emit(currentState.copyWith(
            isProcessing: false,
            operationMessage: 'Tarea creada pero error al actualizar',
            isOperationSuccess: true,
          )),
          (project) => emit(ProjectDetailLoaded(
            project: project,
            operationMessage: 'Tarea agregada exitosamente',
            isOperationSuccess: true,
          )),
        );
      },
    );
  }

  /// Actualizar estado de tarea
  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true, clearMessage: true));

    final result = await _projectRepository.updateTaskStatus(
      projectId: _currentProjectId!,
      taskId: event.taskId,
      status: event.status,
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(
          isProcessing: false,
          operationMessage: failure.message,
          isOperationSuccess: false,
        ));
      },
      (task) async {
        // Actualizar tarea en la lista local
        final updatedTasks = currentState.project.tasks.map((t) {
          if (t.taskId == event.taskId) {
            return t.copyWith(status: event.status);
          }
          return t;
        }).toList();

        emit(ProjectDetailLoaded(
          project: currentState.project.copyWith(tasks: updatedTasks),
          operationMessage: 'Estado actualizado',
          isOperationSuccess: true,
        ));
      },
    );
  }

  /// Eliminar tarea
  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true, clearMessage: true));

    final result = await _projectRepository.deleteTask(
      projectId: _currentProjectId!,
      taskId: event.taskId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(
        isProcessing: false,
        operationMessage: failure.message,
        isOperationSuccess: false,
      )),
      (_) {
        // Remover tarea de la lista local
        final updatedTasks = currentState.project.tasks
            .where((t) => t.taskId != event.taskId)
            .toList();

        emit(ProjectDetailLoaded(
          project: currentState.project.copyWith(tasks: updatedTasks),
          operationMessage: 'Tarea eliminada',
          isOperationSuccess: true,
        ));
      },
    );
  }

  /// Completar proyecto
  Future<void> _onCompleteProject(
    CompleteProject event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true, clearMessage: true));

    final result = await _projectRepository.completeProject(_currentProjectId!);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isProcessing: false,
        operationMessage: failure.message,
        isOperationSuccess: false,
      )),
      (project) => emit(ProjectDetailLoaded(
        project: project,
        operationMessage: 'Proyecto completado',
        isOperationSuccess: true,
      )),
    );
  }

  /// Eliminar proyecto
  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_currentProjectId == null) return;

    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return;

    emit(currentState.copyWith(isProcessing: true, clearMessage: true));

    final result = await _projectRepository.deleteProject(_currentProjectId!);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isProcessing: false,
        operationMessage: failure.message,
        isOperationSuccess: false,
      )),
      (_) => emit(const ProjectDeleted()),
    );
  }

  /// Limpiar mensaje de operación
  void _onClearOperationMessage(
    ClearOperationMessage event,
    Emitter<ProjectDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is ProjectDetailLoaded) {
      emit(currentState.copyWith(clearMessage: true));
    }
  }
}
