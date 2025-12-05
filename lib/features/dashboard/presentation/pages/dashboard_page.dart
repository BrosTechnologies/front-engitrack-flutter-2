// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/project_card.dart';
import '../widgets/task_item.dart';

/// Página principal del Dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<DashboardBloc>().add(ClearDashboardErrorEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.userProfile == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(RefreshDashboardEvent());
            },
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header con saludo
                SliverToBoxAdapter(
                  child: _buildHeader(state),
                ),

                // Sección de proyectos activos
                SliverToBoxAdapter(
                  child: _buildActiveProjectsSection(state),
                ),

                // Sección de tareas pendientes
                SliverToBoxAdapter(
                  child: _buildTasksSection(state),
                ),

                // Espacio inferior
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DashboardState state) {
    final fullName = state.userProfile?.fullName ?? 'Usuario';
    final firstName = fullName.split(' ').first;
    final greeting = _getTimeBasedGreeting();

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hola, $firstName',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar o icono de notificaciones
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Estadísticas rápidas
          _buildQuickStats(state),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardState state) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.folder_outlined,
          label: 'Proyectos',
          value: '${state.activeProjects.length}',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.task_outlined,
          label: 'Tareas',
          value: '${state.upcomingTasks.length}',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.warning_amber_outlined,
          label: 'Urgentes',
          value: '${_countOverdueTasks(state)}',
          isAlert: _countOverdueTasks(state) > 0,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    bool isAlert = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isAlert
              ? AppColors.error.withOpacity(0.2)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectsSection(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Proyectos Activos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a la pestaña de proyectos (index 1)
                    final navigator = MainPageNavigator.of(context);
                    if (navigator != null) {
                      navigator.navigateToTab(1);
                    }
                  },
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (state.activeProjects.isEmpty)
            _buildEmptyState(
              icon: Icons.folder_open_outlined,
              message: 'No hay proyectos activos',
            )
          else
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.activeProjects.length,
                itemBuilder: (context, index) {
                  final project = state.activeProjects[index];
                  return ProjectCard(
                    project: project,
                    index: index,
                    onTap: () {
                      context.push('/projects/${project.id}');
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tareas Pendientes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Próximos 7 días',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          if (state.upcomingTasks.isEmpty)
            _buildEmptyState(
              icon: Icons.task_alt_outlined,
              message: '¡Sin tareas pendientes!',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.upcomingTasks.length,
              itemBuilder: (context, index) {
                final taskWithProject = state.upcomingTasks[index];
                return TaskItem(
                  task: taskWithProject.task,
                  projectName: taskWithProject.projectName,
                  isToggling: state.togglingTaskId == taskWithProject.task.taskId,
                  onToggle: () {
                    context.read<DashboardBloc>().add(
                          ToggleTaskStatusEvent(
                            projectId: taskWithProject.projectId,
                            taskId: taskWithProject.task.taskId,
                          ),
                        );
                  },
                  onTap: () {
                    // Navegar al proyecto
                    context.push('/projects/${taskWithProject.projectId}');
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  int _countOverdueTasks(DashboardState state) {
    return state.upcomingTasks.where((t) => t.task.isOverdue).length;
  }
}
