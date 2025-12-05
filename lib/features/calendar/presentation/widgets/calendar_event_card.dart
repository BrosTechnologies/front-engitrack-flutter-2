// lib/features/calendar/presentation/widgets/calendar_event_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../projects/domain/enums/priority.dart';
import '../../../projects/domain/enums/task_status.dart';
import '../bloc/calendar_state.dart';

/// Widget para mostrar un evento del calendario
class CalendarEventCard extends StatelessWidget {
  final CalendarEventItem event;
  final VoidCallback? onTap;

  const CalendarEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final isCompleted = event.task.status == TaskStatus.done;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: priorityColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de estado
              _buildStatusIndicator(isCompleted),
              const SizedBox(width: 12),

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la tarea
                    Text(
                      event.task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Nombre del proyecto
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.projectName,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Información adicional
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(isCompleted),
                  const SizedBox(height: 8),
                  _buildPriorityBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isCompleted) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCompleted
              ? AppColors.success
              : AppColors.textSecondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (event.task.status) {
      case TaskStatus.done:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Completada';
        break;
      case TaskStatus.inProgress:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        label = 'En progreso';
        break;
      case TaskStatus.pending:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'Pendiente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color badgeColor;
    String label;

    switch (event.projectPriority) {
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor() {
    switch (event.projectPriority) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }
}
