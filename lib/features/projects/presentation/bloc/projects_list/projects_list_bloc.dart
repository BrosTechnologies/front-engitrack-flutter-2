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

  /// Lista completa de proyectos (cache)
  List<Project> _allProjects = [];

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
        _allProjects = projects;
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
        _allProjects = projects;
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
    // Usar cache si el estado actual es Empty con filtros
    final projects = _allProjects.isNotEmpty ? _allProjects : 
        (state is ProjectsListLoaded ? (state as ProjectsListLoaded).projects : <Project>[]);
    
    if (projects.isEmpty) return;

    final query = event.query.trim().toLowerCase();
    final currentStatusFilter = state is ProjectsListLoaded 
        ? (state as ProjectsListLoaded).currentStatusFilter 
        : null;
    
    if (query.isEmpty) {
      // Limpiar búsqueda, mantener otros filtros
      final filtered = _applyFilters(projects, currentStatusFilter, null);
      
      if (filtered.isEmpty && currentStatusFilter != null) {
        emit(ProjectsListEmpty(hasFilters: true));
      } else {
        emit(ProjectsListLoaded(
          projects: projects,
          filteredProjects: filtered,
          currentStatusFilter: currentStatusFilter,
        ));
      }
    } else {
      // Aplicar búsqueda
      final filtered = _applyFilters(projects, currentStatusFilter, query);
      
      if (filtered.isEmpty) {
        emit(const ProjectsListEmpty(hasFilters: true));
      } else {
        emit(ProjectsListLoaded(
          projects: projects,
          filteredProjects: filtered,
          currentStatusFilter: currentStatusFilter,
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
    // Usar cache si el estado actual es Empty con filtros
    final projects = _allProjects.isNotEmpty ? _allProjects : 
        (state is ProjectsListLoaded ? (state as ProjectsListLoaded).projects : <Project>[]);
    
    if (projects.isEmpty) {
      // Si no hay proyectos, recargar
      add(const LoadProjects());
      return;
    }

    final currentSearchQuery = state is ProjectsListLoaded 
        ? (state as ProjectsListLoaded).currentSearchQuery 
        : null;

    final filtered = _applyFilters(projects, event.status, currentSearchQuery);

    if (filtered.isEmpty) {
      emit(const ProjectsListEmpty(hasFilters: true));
    } else {
      emit(ProjectsListLoaded(
        projects: projects,
        filteredProjects: filtered,
        currentStatusFilter: event.status,
        currentSearchQuery: currentSearchQuery,
      ));
    }
  }

  /// Limpiar todos los filtros
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProjectsListState> emit,
  ) async {
    if (_allProjects.isNotEmpty) {
      emit(ProjectsListLoaded(projects: _allProjects));
    } else {
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
