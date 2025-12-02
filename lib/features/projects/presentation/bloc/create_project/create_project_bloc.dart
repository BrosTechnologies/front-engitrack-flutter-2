// lib/features/projects/presentation/bloc/create_project/create_project_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/auth_manager.dart';
import '../../../domain/repositories/project_repository.dart';
import 'create_project_event.dart';
import 'create_project_state.dart';

/// Bloc para gestionar la creación/edición de proyectos
class CreateProjectBloc extends Bloc<CreateProjectEvent, CreateProjectState> {
  final ProjectRepository _projectRepository;
  final AuthManager _authManager;

  CreateProjectBloc(this._projectRepository, this._authManager)
      : super(const CreateProjectInitial()) {
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<ResetForm>(_onResetForm);
  }

  /// Crear nuevo proyecto
  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<CreateProjectState> emit,
  ) async {
    emit(const CreateProjectSubmitting());

    // Obtener ID del usuario actual
    final userId = await _authManager.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(const CreateProjectError('No se pudo obtener el usuario actual'));
      return;
    }

    final result = await _projectRepository.createProject(
      name: event.name,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      budget: event.budget,
      priority: event.priority,
      ownerUserId: userId,
      initialTasks: event.initialTasks,
    );

    result.fold(
      (failure) => emit(CreateProjectError(failure.message)),
      (project) => emit(CreateProjectSuccess(project: project)),
    );
  }

  /// Actualizar proyecto existente
  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<CreateProjectState> emit,
  ) async {
    emit(const CreateProjectSubmitting());

    final result = await _projectRepository.updateProject(
      projectId: event.projectId,
      name: event.name,
      description: event.description,
      budget: event.budget,
      endDate: event.endDate,
      priority: event.priority,
    );

    result.fold(
      (failure) => emit(CreateProjectError(failure.message)),
      (project) => emit(CreateProjectSuccess(
        project: project,
        isUpdate: true,
      )),
    );
  }

  /// Resetear formulario
  void _onResetForm(
    ResetForm event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(const CreateProjectInitial());
  }
}
