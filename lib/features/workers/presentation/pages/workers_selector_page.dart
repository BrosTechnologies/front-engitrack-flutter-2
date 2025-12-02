// lib/features/workers/presentation/pages/workers_selector_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/worker.dart';
import '../../domain/repositories/worker_repository.dart';
import '../bloc/workers_list/workers_list_bloc.dart';
import '../bloc/workers_list/workers_list_event.dart';
import '../bloc/workers_list/workers_list_state.dart';
import '../bloc/project_workers/project_workers_bloc.dart';
import '../bloc/project_workers/project_workers_event.dart';
import '../bloc/project_workers/project_workers_state.dart';
import '../widgets/worker_card.dart';
import '../widgets/assign_worker_dialog.dart';

/// Página para seleccionar workers (puede usarse para asignar a proyecto)
class WorkersSelectorPage extends StatelessWidget {
  /// ID del proyecto al que se quiere asignar (null si solo es listado)
  final String? projectId;

  /// Nombre del proyecto (para mostrar en título)
  final String? projectName;

  const WorkersSelectorPage({
    super.key,
    this.projectId,
    this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WorkersListBloc(GetIt.instance<WorkerRepository>())
            ..add(const LoadWorkersEvent()),
        ),
        if (projectId != null)
          BlocProvider(
            create: (_) =>
                ProjectWorkersBloc(GetIt.instance<WorkerRepository>()),
          ),
      ],
      child: _WorkersSelectorContent(
        projectId: projectId,
        projectName: projectName,
      ),
    );
  }
}

class _WorkersSelectorContent extends StatelessWidget {
  final String? projectId;
  final String? projectName;

  const _WorkersSelectorContent({
    this.projectId,
    this.projectName,
  });

  bool get isAssigningMode => projectId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isAssigningMode
              ? 'Agregar a ${projectName ?? 'proyecto'}'
              : 'Trabajadores',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Botón para crear nuevo worker
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () async {
              final result = await context.push<Worker>('/worker-form');
              if (result != null && context.mounted) {
                context.read<WorkersListBloc>().add(const RefreshWorkersEvent());
              }
            },
            tooltip: 'Nuevo trabajador',
          ),
        ],
      ),
      body: BlocListener<ProjectWorkersBloc, ProjectWorkersState>(
        listener: (context, state) {
          if (state is WorkerAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          } else if (state is ProjectWorkersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<WorkersListBloc, WorkersListState>(
          builder: (context, state) {
            if (state is WorkersListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WorkersListError) {
              return _buildErrorState(context, state.message);
            }

            if (state is WorkersListLoaded) {
              if (state.workers.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildWorkersList(context, state.workers);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: !isAssigningMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await context.push<Worker>('/worker-form');
                if (result != null && context.mounted) {
                  context
                      .read<WorkersListBloc>()
                      .add(const RefreshWorkersEvent());
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo'),
            )
          : null,
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<WorkersListBloc>().add(const LoadWorkersEvent());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin trabajadores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer trabajador para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push<Worker>('/worker-form');
                if (result != null && context.mounted) {
                  context
                      .read<WorkersListBloc>()
                      .add(const RefreshWorkersEvent());
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Crear trabajador'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersList(BuildContext context, List<Worker> workers) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkersListBloc>().add(const RefreshWorkersEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];
          return WorkerCard(
            worker: worker,
            selectorMode: isAssigningMode,
            onTap: () {
              if (isAssigningMode) {
                _showAssignDialog(context, worker);
              } else {
                // Ir a detalle o editar
                context.push('/worker-form/${worker.id}');
              }
            },
            onEdit: isAssigningMode
                ? null
                : () {
                    context.push('/worker-form/${worker.id}');
                  },
            onDelete: isAssigningMode
                ? null
                : () {
                    _confirmDelete(context, worker);
                  },
          );
        },
      ),
    );
  }

  void _showAssignDialog(BuildContext context, Worker worker) {
    AssignWorkerDialog.show(
      context,
      worker: worker,
      onConfirm: (startDate, endDate) {
        context.read<ProjectWorkersBloc>().add(
              AssignWorkerEvent(
                projectId: projectId!,
                workerId: worker.id,
                startDate: startDate,
                endDate: endDate,
              ),
            );
      },
    );
  }

  void _confirmDelete(BuildContext context, Worker worker) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar trabajador'),
        content: Text(
          '¿Estás seguro de eliminar a ${worker.fullName}?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkersListBloc>().add(DeleteWorkerEvent(worker.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
