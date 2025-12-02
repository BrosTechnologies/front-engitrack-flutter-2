// lib/features/projects/presentation/bloc/projects_list/projects_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/enums/project_status.dart';
import '../../../domain/repositories/project_repository.dart';
import 'projects_list_event.dart';
import 'projects_list_state.dart';

/// Bloc para gestionar la lista de proyectos
class ProjectsListBloc extends Bloc<ProjectsListEvent, ProjectsListState> {
  final ProjectRepository _projectRepository;

  ProjectsListBloc(this._projectRepository) : super(const ProjectsListInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
    on<SearchProjects>(_onSearchProjects);
    on<FilterByStatus>(_onFilterByStatus);
    on<ClearFilters>(_onClearFilters);
  }

  /// Carga inicial de proyectos
  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsListState> emit,
  ) async {
    emit(const ProjectsListLoading());

    final result = await _projectRepository.getProjects();

    result.fold(
      (failure) => emit(ProjectsListError(failure.message)),
      (projects) {
        if (projects.isEmpty) {
          emit(const ProjectsListEmpty());
        } else {
          emit(ProjectsListLoaded(projects: projects));
        }
      },
    );
  }

  /// Refrescar lista de proyectos
  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectsListState> emit,
  ) async {
    // Mantener el estado actual mientras se refresca
    final currentState = state;

    final result = await _projectRepository.getProjects();

    result.fold(
      (failure) {
        // Si hay error, mantener estado anterior si es posible
        if (currentState is ProjectsListLoaded) {
          emit(currentState);
        } else {
          emit(ProjectsListError(failure.message));
        }
      },
      (projects) {
        if (projects.isEmpty) {
          emit(const ProjectsListEmpty());
        } else {
          // Aplicar filtros existentes si los hay
          if (currentState is ProjectsListLoaded) {
            final filtered = _applyFilters(
              projects,
              currentState.currentStatusFilter,
              currentState.currentSearchQuery,
            );
            emit(ProjectsListLoaded(
              projects: projects,
              filteredProjects: filtered,
              currentStatusFilter: currentState.currentStatusFilter,
              currentSearchQuery: currentState.currentSearchQuery,
            ));
          } else {
            emit(ProjectsListLoaded(projects: projects));
          }
        }
      },
    );
  }

  /// Buscar proyectos
  Future<void> _onSearchProjects(
    SearchProjects event,
    Emitter<ProjectsListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectsListLoaded) return;

    final query = event.query.trim().toLowerCase();
    
    if (query.isEmpty) {
      // Limpiar búsqueda, mantener otros filtros
      final filtered = _applyFilters(
        currentState.projects,
        currentState.currentStatusFilter,
        null,
      );
      emit(currentState.copyWith(
        filteredProjects: filtered,
        clearSearchQuery: true,
      ));
    } else {
      // Aplicar búsqueda
      final filtered = _applyFilters(
        currentState.projects,
        currentState.currentStatusFilter,
        query,
      );
      
      if (filtered.isEmpty) {
        emit(const ProjectsListEmpty(hasFilters: true));
      } else {
        emit(currentState.copyWith(
          filteredProjects: filtered,
          currentSearchQuery: query,
        ));
      }
    }
  }

  /// Filtrar por estado
  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<ProjectsListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectsListLoaded) return;

    final filtered = _applyFilters(
      currentState.projects,
      event.status,
      currentState.currentSearchQuery,
    );

    if (filtered.isEmpty) {
      emit(const ProjectsListEmpty(hasFilters: true));
    } else {
      emit(currentState.copyWith(
        filteredProjects: filtered,
        currentStatusFilter: event.status,
        clearStatusFilter: event.status == null,
      ));
    }
  }

  /// Limpiar todos los filtros
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProjectsListState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is ProjectsListLoaded) {
      emit(ProjectsListLoaded(projects: currentState.projects));
    } else if (currentState is ProjectsListEmpty) {
      // Recargar proyectos
      add(const LoadProjects());
    }
  }

  /// Aplica filtros a la lista de proyectos
  List<Project> _applyFilters(
    List<Project> projects,
    ProjectStatus? status,
    String? searchQuery,
  ) {
    var filtered = projects.toList();

    // Filtrar por estado
    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    // Filtrar por búsqueda
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final descMatch = p.description?.toLowerCase().contains(query) ?? false;
        return nameMatch || descMatch;
      }).toList();
    }

    return filtered;
  }
}
