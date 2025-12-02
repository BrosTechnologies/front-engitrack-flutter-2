// lib/features/projects/presentation/widgets/project_stats_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

/// Widget card con estadísticas detalladas del proyecto
class ProjectStatsCard extends StatelessWidget {
  /// Proyecto a mostrar
  final Project project;

  const ProjectStatsCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges de estado y prioridad
            Row(
              children: [
                ProjectStatusBadge(
                  status: project.status,
                  showIcon: true,
                  size: StatusBadgeSize.medium,
                ),
                const SizedBox(width: 8),
                PriorityBadge(
                  priority: project.priority,
                  size: BadgeSize.medium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Descripción
            if (project.description != null &&
                project.description!.isNotEmpty) ...[
              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fechas y presupuesto
            _buildInfoSection(),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Progreso de tareas
            _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        if (project.startDate != null)
          _buildInfoItem(
            icon: Icons.play_circle_outline,
            label: 'Inicio',
            value: _formatDate(project.startDate!),
          ),
        if (project.endDate != null)
          _buildInfoItem(
            icon: Icons.flag_outlined,
            label: 'Límite',
            value: _formatDate(project.endDate!),
            isWarning: project.isOverdue,
          ),
        if (project.budget != null)
          _buildInfoItem(
            icon: Icons.attach_money,
            label: 'Presupuesto',
            value: _formatBudget(project.budget!),
          ),
        if (project.daysRemaining != null)
          _buildInfoItem(
            icon: Icons.hourglass_empty,
            label: 'Días restantes',
            value: '${project.daysRemaining}',
            isWarning: project.daysRemaining! < 0,
          ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: isWarning ? Colors.red : Colors.grey.shade500,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isWarning ? Colors.red : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              '${project.progressPercentage}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getProgressColor(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: project.progress,
            backgroundColor: Colors.grey.shade200,
            color: _getProgressColor(),
            minHeight: 8,
          ),
        ),

        const SizedBox(height: 12),

        // Estadísticas de tareas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTaskStat(
              count: project.pendingTasks,
              label: 'Pendientes',
              color: Colors.grey,
            ),
            _buildTaskStat(
              count: project.inProgressTasks,
              label: 'En progreso',
              color: const Color(0xFF007AFF),
            ),
            _buildTaskStat(
              count: project.completedTasks,
              label: 'Completadas',
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskStat({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  String _formatBudget(double budget) {
    final format = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 0,
    );
    return format.format(budget);
  }

  Color _getProgressColor() {
    if (project.isOverdue) return Colors.red;
    if (project.isCompleted) return Colors.green;
    if (project.progress >= 0.7) return Colors.green;
    if (project.progress >= 0.3) return const Color(0xFF007AFF);
    return Colors.orange;
  }
}
