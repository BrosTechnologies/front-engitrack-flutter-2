// lib/features/projects/presentation/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';

/// Widget card para mostrar una tarea
class TaskCard extends StatelessWidget {
  /// Tarea a mostrar
  final Task task;

  /// Callback cuando se toca la tarea (cambiar estado)
  final VoidCallback? onTap;

  /// Callback cuando se elimina la tarea
  final VoidCallback? onDelete;

  /// Si está deshabilitada la interacción
  final bool isEnabled;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.taskId),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isOverdue
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox / Estado
              _buildStatusIndicator(),
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted
                            ? Colors.grey
                            : const Color(0xFF1F2937),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    // Fecha de vencimiento
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: task.isOverdue
                                ? Colors.red
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: task.isOverdue
                                  ? Colors.red
                                  : Colors.grey.shade500,
                            ),
                          ),
                          if (task.isOverdue) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Vencida',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Indicador de siguiente estado
              if (isEnabled && onTap != null)
                Icon(
                  _getNextStatusIcon(),
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: task.status.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: task.status.color,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? Icon(
                Icons.check,
                size: 14,
                color: task.status.color,
              )
            : task.isInProgress
                ? Icon(
                    Icons.timelapse,
                    size: 14,
                    color: task.status.color,
                  )
                : null,
      ),
    );
  }

  IconData _getNextStatusIcon() {
    switch (task.status) {
      case TaskStatus.pending:
        return Icons.play_arrow;
      case TaskStatus.inProgress:
        return Icons.check;
      case TaskStatus.done:
        return Icons.refresh;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoy';
    } else if (taskDate == tomorrow) {
      return 'Mañana';
    } else {
      return DateFormat('dd MMM', 'es').format(date);
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar tarea'),
            content: Text(
              '¿Estás seguro de eliminar "${task.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
