// lib/features/dashboard/presentation/widgets/task_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../projects/domain/entities/task.dart';
import '../../../projects/domain/enums/task_status.dart';

/// Item de tarea para mostrar en la lista del dashboard
class TaskItem extends StatelessWidget {
  final Task task;
  final String projectName;
  final bool isToggling;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.projectName,
    this.isToggling = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isDone = task.status == TaskStatus.done;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue && !isDone
                ? AppColors.error.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            width: isOverdue && !isDone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            _buildCheckbox(isDone),
            const SizedBox(width: 12),

            // Contenido principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la tarea
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Nombre del proyecto
                  Text(
                    projectName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Fecha y estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(),
                if (task.dueDate != null) ...[
                  const SizedBox(height: 6),
                  _buildDateBadge(isOverdue),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isDone) {
    return GestureDetector(
      onTap: isToggling ? null : onToggle,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDone ? AppColors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDone ? AppColors.success : AppColors.textSecondary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: isToggling
            ? const Padding(
                padding: EdgeInsets.all(4),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : isDone
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : null,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (task.status) {
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

  Widget _buildDateBadge(bool isOverdue) {
    final formattedDate = _formatDueDate();
    final textColor = isOverdue && task.status != TaskStatus.done
        ? AppColors.error
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue && task.status != TaskStatus.done
              ? Icons.warning_rounded
              : Icons.calendar_today_outlined,
          size: 12,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: isOverdue && task.status != TaskStatus.done
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDueDate() {
    if (task.dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (dueDate.isAtSameMomentAs(today)) {
      return 'Hoy';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return 'Mañana';
    } else if (dueDate.isBefore(today)) {
      final daysOverdue = today.difference(dueDate).inDays;
      return 'Hace $daysOverdue ${daysOverdue == 1 ? 'día' : 'días'}';
    } else {
      return DateFormat('dd MMM', 'es_ES').format(task.dueDate!);
    }
  }
}
