// lib/features/profile/presentation/widgets/profile_stats_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_stats.dart';

/// Widget card con estadísticas del usuario
class ProfileStatsCard extends StatelessWidget {
  /// Estadísticas del usuario
  final UserStats stats;

  /// Si está cargando
  final bool isLoading;

  const ProfileStatsCard({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 50,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      value: stats.projectsCount.toString(),
                      label: 'Proyectos',
                      icon: Icons.folder_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _StatItem(
                      value: stats.tasksCount.toString(),
                      label: 'Tareas',
                      icon: Icons.task_outlined,
                      color: AppColors.warning,
                    ),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _StatItem(
                      value: stats.completedTasksCount.toString(),
                      label: 'Completadas',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
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
}
