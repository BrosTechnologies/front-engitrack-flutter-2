// lib/features/projects/presentation/pages/projects_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/navigation/app_router.dart';
import '../../domain/enums/project_status.dart';
import '../bloc/projects_list/projects_list_bloc.dart';
import '../bloc/projects_list/projects_list_event.dart';
import '../bloc/projects_list/projects_list_state.dart';
import '../widgets/project_card.dart';

/// Página de lista de proyectos
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProjectsListBloc>()..add(const LoadProjects()),
      child: const _ProjectsPageContent(),
    );
  }
}

class _ProjectsPageContent extends StatefulWidget {
  const _ProjectsPageContent();

  @override
  State<_ProjectsPageContent> createState() => _ProjectsPageContentState();
}

class _ProjectsPageContentState extends State<_ProjectsPageContent> {
  final TextEditingController _searchController = TextEditingController();
  ProjectStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Proyectos'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await context.push(AppRouter.createProject);
              if (result == true && context.mounted) {
                // Refresh después de crear proyecto
                context.read<ProjectsListBloc>().add(const RefreshProjects());
                // Reset filtro a "Todos"
                setState(() => _selectedStatus = null);
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo proyecto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          _buildSearchAndFilters(),

          // Lista de proyectos
          Expanded(
            child: BlocBuilder<ProjectsListBloc, ProjectsListState>(
              builder: (context, state) {
                if (state is ProjectsListLoading) {
                  return _buildLoading();
                } else if (state is ProjectsListError) {
                  return _buildError(state.message);
                } else if (state is ProjectsListEmpty) {
                  return _buildEmpty(state.hasFilters);
                } else if (state is ProjectsListLoaded) {
                  return _buildProjectsList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(AppRouter.createProject);
          if (result == true && context.mounted) {
            context.read<ProjectsListBloc>().add(const RefreshProjects());
            setState(() => _selectedStatus = null);
          }
        },
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar proyectos...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProjectsListBloc>().add(
                              const SearchProjects(''),
                            );
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              context.read<ProjectsListBloc>().add(SearchProjects(value));
            },
          ),

          const SizedBox(height: 12),

          // Filtros de estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: _selectedStatus == null,
                  onTap: () => _onFilterSelected(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: ProjectStatus.active.displayName,
                  isSelected: _selectedStatus == ProjectStatus.active,
                  color: ProjectStatus.active.color,
                  onTap: () => _onFilterSelected(ProjectStatus.active),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: ProjectStatus.paused.displayName,
                  isSelected: _selectedStatus == ProjectStatus.paused,
                  color: ProjectStatus.paused.color,
                  onTap: () => _onFilterSelected(ProjectStatus.paused),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: ProjectStatus.completed.displayName,
                  isSelected: _selectedStatus == ProjectStatus.completed,
                  color: ProjectStatus.completed.color,
                  onTap: () => _onFilterSelected(ProjectStatus.completed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF007AFF);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _onFilterSelected(ProjectStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<ProjectsListBloc>().add(FilterByStatus(status));
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF007AFF),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar proyectos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProjectsListBloc>().add(const LoadProjects());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_box.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.folder_open,
                size: 80,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'Sin resultados' : 'No hay proyectos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Intenta con otros filtros de búsqueda'
                  : 'Crea un nuevo proyecto para empezar a colaborar con tu equipo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            if (hasFilters)
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedStatus = null);
                  context.read<ProjectsListBloc>().add(const ClearFilters());
                },
                child: const Text('Limpiar filtros'),
              )
            else
              ElevatedButton.icon(
                onPressed: () => context.push(AppRouter.createProject),
                icon: const Icon(Icons.add),
                label: const Text('Crear proyecto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(ProjectsListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectsListBloc>().add(const RefreshProjects());
      },
      color: const Color(0xFF007AFF),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.displayProjects.length,
        itemBuilder: (context, index) {
          final project = state.displayProjects[index];
          return ProjectCard(
            project: project,
            onTap: () => context.push(
              AppRouter.projectDetail.replaceFirst(':id', project.id),
            ),
          );
        },
      ),
    );
  }
}
