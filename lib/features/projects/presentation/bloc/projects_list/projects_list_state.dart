// lib/features/projects/presentation/bloc/projects_list/projects_list_state.dart

import 'dart:math';
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
  
  /// Página actual (1-indexed)
  final int currentPage;
  
  /// Número de elementos por página
  final int itemsPerPage;

  const ProjectsListLoaded({
    required this.projects,
    List<Project>? filteredProjects,
    this.currentStatusFilter,
    this.currentSearchQuery,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  }) : filteredProjects = filteredProjects ?? projects;

  /// Número total de páginas
  int get totalPages => (filteredProjects.length / itemsPerPage).ceil();
  
  /// Lista de proyectos a mostrar (paginada)
  List<Project> get displayProjects {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, filteredProjects.length);
    
    if (startIndex >= filteredProjects.length) {
      return [];
    }
    
    return filteredProjects.sublist(startIndex, endIndex);
  }
  
  /// Total de proyectos filtrados
  int get totalFilteredProjects => filteredProjects.length;

  /// Verifica si hay filtros aplicados
  bool get hasFilters =>
      currentStatusFilter != null ||
      (currentSearchQuery != null && currentSearchQuery!.isNotEmpty);
  
  /// Verifica si hay página anterior
  bool get hasPreviousPage => currentPage > 1;
  
  /// Verifica si hay página siguiente
  bool get hasNextPage => currentPage < totalPages;

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
    int? currentPage,
    int? itemsPerPage,
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
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  @override
  List<Object?> get props => [
        projects,
        filteredProjects,
        currentStatusFilter,
        currentSearchQuery,
        currentPage,
        itemsPerPage,
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
