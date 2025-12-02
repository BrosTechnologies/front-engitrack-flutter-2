// lib/features/workers/presentation/widgets/worker_assignment_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/worker_assignment.dart';

/// Widget card para mostrar una asignación de un worker
class WorkerAssignmentCard extends StatelessWidget {
  /// Asignación a mostrar
  final WorkerAssignment assignment;

  /// Callback cuando se toca el card (ir al proyecto)
  final VoidCallback? onTap;

  const WorkerAssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del proyecto
              _buildProjectIcon(),
              const SizedBox(width: 12),

              // Información de la asignación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del proyecto
                    Text(
                      assignment.projectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Fechas de asignación
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateRange(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Días restantes si está activo
                    if (assignment.isActive && assignment.daysRemaining != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse_outlined,
                            size: 14,
                            color: _getDaysRemainingColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDaysRemainingText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDaysRemainingColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Badge de estado
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.business_center_outlined,
        color: _getStatusColor(),
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final label = _getStatusLabel();
    final icon = _getStatusIcon();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final startStr = dateFormat.format(assignment.startDate);

    if (assignment.endDate != null) {
      final endStr = dateFormat.format(assignment.endDate!);
      return '$startStr - $endStr';
    }

    return 'Desde $startStr';
  }

  String _getDaysRemainingText() {
    final days = assignment.daysRemaining;
    if (days == null) return '';
    if (days < 0) return 'Vencido hace ${days.abs()} días';
    if (days == 0) return 'Vence hoy';
    if (days == 1) return 'Vence mañana';
    return '$days días restantes';
  }

  Color _getDaysRemainingColor() {
    final days = assignment.daysRemaining;
    if (days == null) return Colors.grey;
    if (days < 0) return AppColors.error;
    if (days <= 3) return AppColors.warning;
    return AppColors.success;
  }

  Color _getStatusColor() {
    if (assignment.isCompleted) return Colors.grey;
    if (assignment.isActive) return AppColors.success;
    return AppColors.warning; // Pendiente
  }

  String _getStatusLabel() {
    if (assignment.isCompleted) return 'Finalizado';
    if (assignment.isActive) return 'Activo';
    return 'Pendiente';
  }

  IconData _getStatusIcon() {
    if (assignment.isCompleted) return Icons.check_circle_outline;
    if (assignment.isActive) return Icons.play_circle_outline;
    return Icons.pending_outlined;
  }
}
