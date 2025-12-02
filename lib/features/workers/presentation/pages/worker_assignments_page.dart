// lib/features/workers/presentation/pages/worker_assignments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/worker_repository.dart';
import '../bloc/worker_assignments/worker_assignments_bloc.dart';
import '../bloc/worker_assignments/worker_assignments_event.dart';
import '../bloc/worker_assignments/worker_assignments_state.dart';
import '../widgets/worker_assignment_card.dart';

/// Página para ver las asignaciones de un worker (mis proyectos)
class WorkerAssignmentsPage extends StatelessWidget {
  /// ID del worker
  final String workerId;

  /// Nombre del worker (para mostrar en el título)
  final String? workerName;

  const WorkerAssignmentsPage({
    super.key,
    required this.workerId,
    this.workerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkerAssignmentsBloc(GetIt.instance<WorkerRepository>())
        ..add(LoadWorkerAssignmentsEvent(workerId)),
      child: _WorkerAssignmentsContent(
        workerId: workerId,
        workerName: workerName,
      ),
    );
  }
}

class _WorkerAssignmentsContent extends StatelessWidget {
  final String workerId;
  final String? workerName;

  const _WorkerAssignmentsContent({
    required this.workerId,
    this.workerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(workerName != null ? 'Proyectos de $workerName' : 'Mis Proyectos'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<WorkerAssignmentsBloc, WorkerAssignmentsState>(
        builder: (context, state) {
          if (state is WorkerAssignmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkerAssignmentsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is WorkerAssignmentsLoaded) {
            if (state.assignments.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAssignmentsList(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
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
                context.read<WorkerAssignmentsBloc>().add(
                      LoadWorkerAssignmentsEvent(workerId),
                    );
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin proyectos asignados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no tienes proyectos asignados.\nContacta con tu supervisor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsList(
    BuildContext context,
    WorkerAssignmentsLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkerAssignmentsBloc>().add(
              RefreshWorkerAssignmentsEvent(workerId),
            );
      },
      child: CustomScrollView(
        slivers: [
          // Header con estadísticas
          SliverToBoxAdapter(
            child: _buildStatsHeader(state),
          ),

          // Proyectos activos
          if (state.activeAssignments.isNotEmpty) ...[
            _buildSectionHeader('Proyectos Activos', state.activeAssignments.length),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final assignment = state.activeAssignments[index];
                  return WorkerAssignmentCard(
                    assignment: assignment,
                    onTap: () {
                      context.push('/projects/${assignment.projectId}');
                    },
                  );
                },
                childCount: state.activeAssignments.length,
              ),
            ),
          ],

          // Proyectos pendientes
          if (state.pendingAssignments.isNotEmpty) ...[
            _buildSectionHeader('Próximos Proyectos', state.pendingAssignments.length),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final assignment = state.pendingAssignments[index];
                  return WorkerAssignmentCard(
                    assignment: assignment,
                    onTap: () {
                      context.push('/projects/${assignment.projectId}');
                    },
                  );
                },
                childCount: state.pendingAssignments.length,
              ),
            ),
          ],

          // Proyectos completados
          if (state.completedAssignments.isNotEmpty) ...[
            _buildSectionHeader('Completados', state.completedAssignments.length),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final assignment = state.completedAssignments[index];
                  return WorkerAssignmentCard(
                    assignment: assignment,
                    onTap: () {
                      context.push('/projects/${assignment.projectId}');
                    },
                  );
                },
                childCount: state.completedAssignments.length,
              ),
            ),
          ],

          // Espacio inferior
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(WorkerAssignmentsLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.play_circle_outline,
            label: 'Activos',
            value: state.activeAssignments.length.toString(),
            color: AppColors.success,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.pending_outlined,
            label: 'Pendientes',
            value: state.pendingAssignments.length.toString(),
            color: AppColors.warning,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.check_circle_outline,
            label: 'Completados',
            value: state.completedAssignments.length.toString(),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
