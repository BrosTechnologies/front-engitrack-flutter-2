// lib/features/dashboard/presentation/bloc/dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/domain/entities/task.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../../../projects/domain/enums/task_status.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Bloc para manejar el estado del Dashboard
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ProjectRepository _projectRepository;
  final ProfileRepository _profileRepository;

  DashboardBloc(
    this._projectRepository,
    this._profileRepository,
  ) : super(DashboardState.initial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<ToggleTaskStatusEvent>(_onToggleTaskStatus);
    on<ClearDashboardErrorEvent>(_onClearError);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    // Cargar perfil del usuario
    final profileResult = await _profileRepository.getProfile();
    
    // Cargar proyectos
    final projectsResult = await _projectRepository.getProjects();

    profileResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (profile) {
        projectsResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            userProfile: profile,
            errorMessage: failure.message,
          )),
          (projects) {
            // Filtrar proyectos activos (máximo 5)
            final activeProjects = projects
                .where((p) => p.status == ProjectStatus.active)
                .take(5)
                .toList();

            // Extraer y filtrar tareas de los próximos 7 días
            final upcomingTasks = _extractUpcomingTasks(projects);

            emit(state.copyWith(
              isLoading: false,
              userProfile: profile,
              activeProjects: activeProjects,
              upcomingTasks: upcomingTasks,
            ));
          },
        );
      },
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // No mostrar loading completo, solo refrescar datos
    final projectsResult = await _projectRepository.getProjects();

    projectsResult.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (projects) {
        final activeProjects = projects
            .where((p) => p.status == ProjectStatus.active)
            .take(5)
            .toList();

        final upcomingTasks = _extractUpcomingTasks(projects);

        emit(state.copyWith(
          activeProjects: activeProjects,
          upcomingTasks: upcomingTasks,
        ));
      },
    );
  }

  Future<void> _onToggleTaskStatus(
    ToggleTaskStatusEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      isTogglingTask: true,
      togglingTaskId: event.taskId,
    ));

    // Encontrar la tarea actual
    final taskWithProject = state.upcomingTasks.firstWhere(
      (t) => t.task.taskId == event.taskId,
      orElse: () => throw Exception('Tarea no encontrada'),
    );

    // Determinar el nuevo estado
    final newStatus = taskWithProject.task.status == TaskStatus.done
        ? TaskStatus.pending
        : TaskStatus.done;

    final result = await _projectRepository.updateTaskStatus(
      projectId: event.projectId,
      taskId: event.taskId,
      status: newStatus,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isTogglingTask: false,
        clearTogglingTaskId: true,
        errorMessage: failure.message,
      )),
      (updatedTask) {
        // Actualizar la lista de tareas
        final updatedTasks = state.upcomingTasks.map((t) {
          if (t.task.taskId == event.taskId) {
            return TaskWithProject(
              task: updatedTask,
              projectId: t.projectId,
              projectName: t.projectName,
            );
          }
          return t;
        }).toList();

        // Si la tarea se marcó como DONE, quitarla de la lista
        final filteredTasks = updatedTasks
            .where((t) => t.task.status != TaskStatus.done)
            .toList();

        emit(state.copyWith(
          isTogglingTask: false,
          clearTogglingTaskId: true,
          upcomingTasks: filteredTasks,
        ));
      },
    );
  }

  void _onClearError(
    ClearDashboardErrorEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  /// Extrae las tareas de los próximos 7 días que no estén completadas
  List<TaskWithProject> _extractUpcomingTasks(List<dynamic> projects) {
    final List<TaskWithProject> allTasks = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysLater = today.add(const Duration(days: 7));

    for (final project in projects) {
      for (final task in project.tasks) {
        if (_isTaskRelevant(task, today, sevenDaysLater)) {
          allTasks.add(TaskWithProject(
            task: task,
            projectId: project.id,
            projectName: project.name,
          ));
        }
      }
    }

    // Ordenar por fecha de vencimiento
    allTasks.sort((a, b) {
      if (a.task.dueDate == null && b.task.dueDate == null) return 0;
      if (a.task.dueDate == null) return 1;
      if (b.task.dueDate == null) return -1;
      return a.task.dueDate!.compareTo(b.task.dueDate!);
    });

    return allTasks;
  }

  /// Verifica si una tarea es relevante para mostrar en el dashboard
  bool _isTaskRelevant(Task task, DateTime today, DateTime sevenDaysLater) {
    // No mostrar tareas completadas
    if (task.status == TaskStatus.done) return false;

    // Si no tiene fecha, mostrarla igual
    if (task.dueDate == null) return true;

    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    // Mostrar tareas vencidas o dentro de los próximos 7 días
    return dueDate.isBefore(sevenDaysLater) || 
           dueDate.isAtSameMomentAs(sevenDaysLater) ||
           dueDate.isBefore(today); // Incluir atrasadas
  }
}
