// lib/features/projects/data/models/task_dto.dart

import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';

/// DTO para Task del API
/// Maneja la serialización/deserialización de tareas
class TaskDto {
  final String taskId;
  final String projectId;
  final String title;
  final String status;
  final String? dueDate;

  const TaskDto({
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.status,
    this.dueDate,
  });

  /// Crear desde JSON del API
  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      taskId: json['taskId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      dueDate: json['dueDate'] as String?,
    );
  }

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'projectId': projectId,
      'title': title,
      'status': status,
      if (dueDate != null) 'dueDate': dueDate,
    };
  }

  /// Convertir a entidad de dominio
  Task toEntity() {
    return Task(
      taskId: taskId,
      projectId: projectId,
      title: title,
      status: TaskStatus.fromString(status),
      dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
    );
  }

  /// Crear desde entidad de dominio
  factory TaskDto.fromEntity(Task task) {
    return TaskDto(
      taskId: task.taskId,
      projectId: task.projectId,
      title: task.title,
      status: task.status.toApiString(),
      dueDate: task.dueDate?.toIso8601String().split('T').first,
    );
  }
}
