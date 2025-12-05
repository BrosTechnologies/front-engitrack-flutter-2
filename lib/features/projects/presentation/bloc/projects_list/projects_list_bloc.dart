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
    on<ChangePage>(_onChangePage);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
  }

  /// Carga inicial de proyectos
  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsListState> emit,
  ) async {
    emit(const ProjectsListLoading());

    // Pedimos todos los proyectos (pageSize grande) para paginación local
    final result = await _projectRepository.getProjects(
      page: 1,
      pageSize: 1000,
    );

    result.fold(
      (failure) => emit(ProjectsListError(failure.message)),
      (projects) {
        _allProjects = projects;
        if (projects.isEmpty) {
          emit(const ProjectsListEmpty());
        } else {
          emit(ProjectsListLoaded(projects: projects, currentPage: 1));
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

    // Pedimos todos los proyectos para paginación local
    final result = await _projectRepository.getProjects(
      page: 1,
      pageSize: 1000,
    );

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
              currentPage: 1, // Reset to first page on refresh
            ));
          } else {
            emit(ProjectsListLoaded(projects: projects, currentPage: 1));
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
          currentPage: 1, // Reset to first page on search
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
          currentPage: 1, // Reset to first page on search
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
        currentPage: 1, // Reset to first page on filter change
      ));
    }
  }

  /// Limpiar todos los filtros
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProjectsListState> emit,
  ) async {
    if (_allProjects.isNotEmpty) {
      emit(ProjectsListLoaded(projects: _allProjects, currentPage: 1));
    } else {
      // Recargar proyectos
      add(const LoadProjects());
    }
  }

  /// Cambiar a una página específica
  Future<void> _onChangePage(
    ChangePage event,
    Emitter<ProjectsListState> emit,
  ) async {
    if (state is ProjectsListLoaded) {
      final currentState = state as ProjectsListLoaded;
      final newPage = event.page.clamp(1, currentState.totalPages);
      
      if (newPage != currentState.currentPage) {
        emit(currentState.copyWith(currentPage: newPage));
      }
    }
  }

  /// Ir a la página siguiente
  Future<void> _onNextPage(
    NextPage event,
    Emitter<ProjectsListState> emit,
  ) async {
    if (state is ProjectsListLoaded) {
      final currentState = state as ProjectsListLoaded;
      if (currentState.hasNextPage) {
        emit(currentState.copyWith(currentPage: currentState.currentPage + 1));
      }
    }
  }

  /// Ir a la página anterior
  Future<void> _onPreviousPage(
    PreviousPage event,
    Emitter<ProjectsListState> emit,
  ) async {
    if (state is ProjectsListLoaded) {
      final currentState = state as ProjectsListLoaded;
      if (currentState.hasPreviousPage) {
        emit(currentState.copyWith(currentPage: currentState.currentPage - 1));
      }
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
