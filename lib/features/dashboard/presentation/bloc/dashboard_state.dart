// lib/features/dashboard/presentation/bloc/dashboard_state.dart

import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/task.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Estado del DashboardBloc
class DashboardState extends Equatable {
  /// Indica si está cargando datos
  final bool isLoading;

  /// Lista de proyectos activos
  final List<Project> activeProjects;

  /// Lista de tareas de los próximos días
  final List<TaskWithProject> upcomingTasks;

  /// Perfil del usuario actual
  final UserProfile? userProfile;

  /// Mensaje de error si hay alguno
  final String? errorMessage;

  /// Indica si está cambiando el estado de una tarea
  final bool isTogglingTask;

  /// ID de la tarea que se está modificando
  final String? togglingTaskId;

  const DashboardState({
    this.isLoading = false,
    this.activeProjects = const [],
    this.upcomingTasks = const [],
    this.userProfile,
    this.errorMessage,
    this.isTogglingTask = false,
    this.togglingTaskId,
  });

  /// Estado inicial
  factory DashboardState.initial() => const DashboardState(isLoading: true);

  /// Crea una copia con valores modificados
  DashboardState copyWith({
    bool? isLoading,
    List<Project>? activeProjects,
    List<TaskWithProject>? upcomingTasks,
    UserProfile? userProfile,
    String? errorMessage,
    bool clearError = false,
    bool? isTogglingTask,
    String? togglingTaskId,
    bool clearTogglingTaskId = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      activeProjects: activeProjects ?? this.activeProjects,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isTogglingTask: isTogglingTask ?? this.isTogglingTask,
      togglingTaskId: clearTogglingTaskId ? null : (togglingTaskId ?? this.togglingTaskId),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        activeProjects,
        upcomingTasks,
        userProfile,
        errorMessage,
        isTogglingTask,
        togglingTaskId,
      ];
}

/// Wrapper para tarea con información del proyecto
class TaskWithProject extends Equatable {
  final Task task;
  final String projectId;
  final String projectName;

  const TaskWithProject({
    required this.task,
    required this.projectId,
    required this.projectName,
  });

  @override
  List<Object?> get props => [task, projectId, projectName];
}
