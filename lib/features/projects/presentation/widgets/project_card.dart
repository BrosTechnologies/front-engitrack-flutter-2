// lib/features/projects/presentation/widgets/project_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

/// Widget card para mostrar un proyecto en la lista
class ProjectCard extends StatelessWidget {
  /// Proyecto a mostrar
  final Project project;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre y Estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            PriorityBadge(
                              priority: project.priority,
                              size: BadgeSize.small,
                              showIcon: false,
                            ),
                            const SizedBox(width: 8),
                            ProjectStatusBadge(
                              status: project.status,
                              size: StatusBadgeSize.small,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Progreso circular
                  _buildProgressIndicator(),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción (si existe)
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                Text(
                  project.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Info: Fechas y Presupuesto
              Row(
                children: [
                  // Fechas
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatDateRange(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Presupuesto
                  if (project.budget != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        Text(
                          _formatBudget(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Barra de progreso
              _buildProgressBar(),

              const SizedBox(height: 8),

              // Info de tareas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${project.completedTasks}/${project.totalTasks} tareas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${project.progressPercentage}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getProgressColor(),
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

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: project.progress,
            backgroundColor: Colors.grey.shade200,
            color: _getProgressColor(),
            strokeWidth: 4,
          ),
          Text(
            '${project.progressPercentage}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getProgressColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: project.progress,
        backgroundColor: Colors.grey.shade200,
        color: _getProgressColor(),
        minHeight: 6,
      ),
    );
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('dd MMM', 'es');
    
    if (project.startDate != null && project.endDate != null) {
      return '${dateFormat.format(project.startDate!)} - ${dateFormat.format(project.endDate!)}';
    } else if (project.endDate != null) {
      return 'Límite: ${dateFormat.format(project.endDate!)}';
    } else if (project.startDate != null) {
      return 'Inicio: ${dateFormat.format(project.startDate!)}';
    }
    return 'Sin fechas';
  }

  String _formatBudget() {
    if (project.budget == null) return '';
    final format = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 0,
    );
    return format.format(project.budget);
  }

  Color _getProgressColor() {
    if (project.isOverdue) return Colors.red;
    if (project.isCompleted) return Colors.green;
    if (project.progress >= 0.7) return Colors.green;
    if (project.progress >= 0.3) return const Color(0xFF007AFF);
    return Colors.orange;
  }
}
