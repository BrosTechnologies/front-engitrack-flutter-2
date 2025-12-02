// lib/features/projects/presentation/bloc/projects_list/projects_list_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/enums/project_status.dart';

/// Eventos del bloc de lista de proyectos
abstract class ProjectsListEvent extends Equatable {
  const ProjectsListEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de proyectos
class LoadProjects extends ProjectsListEvent {
  const LoadProjects();
}

/// Refrescar lista de proyectos
class RefreshProjects extends ProjectsListEvent {
  const RefreshProjects();
}

/// Buscar proyectos por texto
class SearchProjects extends ProjectsListEvent {
  final String query;

  const SearchProjects(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filtrar proyectos por estado
class FilterByStatus extends ProjectsListEvent {
  final ProjectStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Limpiar filtros
class ClearFilters extends ProjectsListEvent {
  const ClearFilters();
}
