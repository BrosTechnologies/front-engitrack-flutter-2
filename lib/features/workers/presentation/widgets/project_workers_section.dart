// lib/features/workers/presentation/widgets/project_workers_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/project_workers/project_workers_bloc.dart';
import '../bloc/project_workers/project_workers_event.dart';
import '../bloc/project_workers/project_workers_state.dart';
import 'project_worker_card.dart';

/// Widget sección para mostrar los workers de un proyecto
/// Se usa dentro de ProjectDetailPage
class ProjectWorkersSection extends StatelessWidget {
  /// ID del proyecto
  final String projectId;

  /// Callback para ir a agregar worker
  final VoidCallback? onAddWorker;

  const ProjectWorkersSection({
    super.key,
    required this.projectId,
    this.onAddWorker,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectWorkersBloc, ProjectWorkersState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Trabajadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (state is ProjectWorkersLoaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.workers.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: onAddWorker,
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Agregar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Contenido según estado
            _buildContent(context, state),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ProjectWorkersState state) {
    if (state is ProjectWorkersLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ProjectWorkersError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.read<ProjectWorkersBloc>().add(
                      LoadProjectWorkersEvent(projectId),
                    );
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is ProjectWorkersLoaded) {
      if (state.workers.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        children: state.workers.map((worker) {
          return ProjectWorkerCard(
            worker: worker,
            dismissible: true,
            onRemove: () {
              context.read<ProjectWorkersBloc>().add(
                    RemoveWorkerFromProjectEvent(
                      projectId: projectId,
                      workerId: worker.workerId,
                    ),
                  );
            },
          );
        }).toList(),
      );
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin trabajadores asignados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega trabajadores a este proyecto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddWorker,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar trabajador'),
          ),
        ],
      ),
    );
  }
}
