// lib/features/projects/domain/entities/task.dart

import 'package:equatable/equatable.dart';
import '../enums/task_status.dart';

/// Entidad de dominio para Tarea
/// Representa una tarea dentro de un proyecto
class Task extends Equatable {
  /// ID único de la tarea
  final String taskId;

  /// ID del proyecto al que pertenece
  final String projectId;

  /// Título de la tarea
  final String title;

  /// Estado de la tarea
  final TaskStatus status;

  /// Fecha de vencimiento
  final DateTime? dueDate;

  const Task({
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.status,
    this.dueDate,
  });

  /// Verifica si la tarea está completada
  bool get isCompleted => status == TaskStatus.done;

  /// Verifica si la tarea está pendiente
  bool get isPending => status == TaskStatus.pending;

  /// Verifica si la tarea está en progreso
  bool get isInProgress => status == TaskStatus.inProgress;

  /// Verifica si la tarea está vencida
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && !isCompleted;
  }

  /// Días restantes hasta vencimiento
  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Copia con modificaciones
  Task copyWith({
    String? taskId,
    String? projectId,
    String? title,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [taskId, projectId, title, status, dueDate];
}
