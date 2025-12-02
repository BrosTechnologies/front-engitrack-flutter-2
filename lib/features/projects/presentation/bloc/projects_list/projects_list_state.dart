// lib/features/projects/presentation/bloc/projects_list/projects_list_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/enums/project_status.dart';

/// Estados del bloc de lista de proyectos
abstract class ProjectsListState extends Equatable {
  const ProjectsListState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectsListInitial extends ProjectsListState {
  const ProjectsListInitial();
}

/// Cargando proyectos
class ProjectsListLoading extends ProjectsListState {
  const ProjectsListLoading();
}

/// Proyectos cargados exitosamente
class ProjectsListLoaded extends ProjectsListState {
  /// Lista completa de proyectos
  final List<Project> projects;
  
  /// Lista filtrada de proyectos (si hay filtros aplicados)
  final List<Project> filteredProjects;
  
  /// Filtro de estado actual
  final ProjectStatus? currentStatusFilter;
  
  /// Búsqueda actual
  final String? currentSearchQuery;

  const ProjectsListLoaded({
    required this.projects,
    List<Project>? filteredProjects,
    this.currentStatusFilter,
    this.currentSearchQuery,
  }) : filteredProjects = filteredProjects ?? projects;

  /// Lista de proyectos a mostrar
  List<Project> get displayProjects => filteredProjects;

  /// Verifica si hay filtros aplicados
  bool get hasFilters =>
      currentStatusFilter != null ||
      (currentSearchQuery != null && currentSearchQuery!.isNotEmpty);

  /// Número de proyectos por estado
  int get activeCount =>
      projects.where((p) => p.status == ProjectStatus.active).length;
  int get pausedCount =>
      projects.where((p) => p.status == ProjectStatus.paused).length;
  int get completedCount =>
      projects.where((p) => p.status == ProjectStatus.completed).length;

  ProjectsListLoaded copyWith({
    List<Project>? projects,
    List<Project>? filteredProjects,
    ProjectStatus? currentStatusFilter,
    String? currentSearchQuery,
    bool clearStatusFilter = false,
    bool clearSearchQuery = false,
  }) {
    return ProjectsListLoaded(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      currentStatusFilter:
          clearStatusFilter ? null : (currentStatusFilter ?? this.currentStatusFilter),
      currentSearchQuery:
          clearSearchQuery ? null : (currentSearchQuery ?? this.currentSearchQuery),
    );
  }

  @override
  List<Object?> get props => [
        projects,
        filteredProjects,
        currentStatusFilter,
        currentSearchQuery,
      ];
}

/// Error al cargar proyectos
class ProjectsListError extends ProjectsListState {
  final String message;

  const ProjectsListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado vacío (sin proyectos)
class ProjectsListEmpty extends ProjectsListState {
  final bool hasFilters;

  const ProjectsListEmpty({this.hasFilters = false});

  @override
  List<Object?> get props => [hasFilters];
}
