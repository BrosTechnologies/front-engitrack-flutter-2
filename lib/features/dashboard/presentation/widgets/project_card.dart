// lib/features/dashboard/presentation/widgets/project_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/enums/priority.dart';

/// Tarjeta de proyecto para mostrar en el dashboard
class ProjectCard extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback? onTap;

  // Colores alternados para las tarjetas
  static const List<Color> _cardColors = [
    Color(0xFFF0E5D8), // Beige cálido
    Color(0xFFE8F4FD), // Azul claro
    Color(0xFFE8F5E9), // Verde suave
    Color(0xFFFFF3E0), // Naranja suave
    Color(0xFFF3E5F5), // Púrpura suave
  ];

  const ProjectCard({
    super.key,
    required this.project,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _cardColors[index % _cardColors.length];
    final progress = project.progressPercentage.toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre y prioridad
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityBadge(),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción o info adicional
              Expanded(
                child: Text(
                  '${project.totalTasks} tareas • ${project.completedTasks} completadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ),

              // Barra de progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color badgeColor;
    String label;

    switch (project.priority) {
      case Priority.high:
        badgeColor = AppColors.priorityHigh;
        label = 'Alta';
        break;
      case Priority.medium:
        badgeColor = AppColors.priorityMedium;
        label = 'Media';
        break;
      case Priority.low:
        badgeColor = AppColors.priorityLow;
        label = 'Baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return AppColors.success;
    } else if (progress >= 50) {
      return AppColors.primary;
    } else if (progress >= 25) {
      return AppColors.warning;
    } else {
      return AppColors.textSecondary;
    }
  }
}
