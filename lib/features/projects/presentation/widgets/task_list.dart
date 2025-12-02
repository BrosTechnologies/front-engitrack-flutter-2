// lib/features/projects/presentation/widgets/task_list.dart

import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import 'task_card.dart';

/// Widget lista de tareas con header
class TaskList extends StatelessWidget {
  /// Lista de tareas
  final List<Task> tasks;

  /// Callback cuando se toca una tarea
  final Function(Task task)? onTaskTap;

  /// Callback cuando se elimina una tarea
  final Function(Task task)? onTaskDelete;

  /// Callback para agregar tarea
  final VoidCallback? onAddTask;

  /// Si está procesando alguna operación
  final bool isProcessing;

  /// Título de la sección
  final String title;

  /// Si debe mostrar empty state
  final bool showEmptyState;

  const TaskList({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskDelete,
    this.onAddTask,
    this.isProcessing = false,
    this.title = 'Tareas',
    this.showEmptyState = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            if (onAddTask != null)
              IconButton(
                onPressed: isProcessing ? null : onAddTask,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF007AFF),
                tooltip: 'Agregar tarea',
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Lista de tareas
        if (tasks.isEmpty && showEmptyState)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                isEnabled: !isProcessing,
                onTap: onTaskTap != null
                    ? () => onTaskTap!(task)
                    : null,
                onDelete: onTaskDelete != null
                    ? () => onTaskDelete!(task)
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega tareas para organizar tu proyecto',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
          if (onAddTask != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para agrupar tareas por estado
class GroupedTaskList extends StatelessWidget {
  /// Lista de tareas
  final List<Task> tasks;

  /// Callback cuando se toca una tarea
  final Function(Task task)? onTaskTap;

  /// Callback cuando se elimina una tarea
  final Function(Task task)? onTaskDelete;

  /// Callback para agregar tarea
  final VoidCallback? onAddTask;

  /// Si está procesando
  final bool isProcessing;

  const GroupedTaskList({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskDelete,
    this.onAddTask,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => t.status == TaskStatus.pending).toList();
    final inProgress =
        tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con botón agregar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            if (onAddTask != null)
              TextButton.icon(
                onPressed: isProcessing ? null : onAddTask,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007AFF),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (tasks.isEmpty)
          _buildEmptyState()
        else ...[
          // En progreso
          if (inProgress.isNotEmpty)
            _buildSection(
              title: 'En progreso',
              tasks: inProgress,
              color: const Color(0xFF007AFF),
            ),

          // Pendientes
          if (pending.isNotEmpty) ...[
            if (inProgress.isNotEmpty) const SizedBox(height: 16),
            _buildSection(
              title: 'Pendientes',
              tasks: pending,
              color: Colors.grey,
            ),
          ],

          // Completadas
          if (done.isNotEmpty) ...[
            if (pending.isNotEmpty || inProgress.isNotEmpty)
              const SizedBox(height: 16),
            _buildSection(
              title: 'Completadas',
              tasks: done,
              color: Colors.green,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Task> tasks,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${tasks.length})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              isEnabled: !isProcessing,
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
              onDelete: onTaskDelete != null ? () => onTaskDelete!(task) : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          if (onAddTask != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
