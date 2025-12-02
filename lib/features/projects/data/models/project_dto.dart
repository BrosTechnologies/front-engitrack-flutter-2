// lib/features/projects/data/models/project_dto.dart

import '../../domain/entities/project.dart';
import '../../domain/enums/priority.dart';
import '../../domain/enums/project_status.dart';
import 'task_dto.dart';

/// DTO para Project del API
/// Maneja la serialización/deserialización de proyectos
class ProjectDto {
  final String id;
  final String name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final double? budget;
  final String status;
  final dynamic priority; // Puede ser int o String desde el API
  final String ownerUserId;
  final List<TaskDto> tasks;

  const ProjectDto({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.budget,
    required this.status,
    required this.priority,
    required this.ownerUserId,
    this.tasks = const [],
  });

  /// Crear desde JSON del API
  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>? ?? [];

    return ProjectDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'ACTIVE',
      priority: json['priority'] ?? 1,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      tasks: tasksJson
          .map((taskJson) => TaskDto.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (budget != null) 'budget': budget,
      'status': status,
      'priority': priority,
      'ownerUserId': ownerUserId,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  /// Convertir a entidad de dominio
  Project toEntity() {
    return Project(
      id: id,
      name: name,
      description: description,
      startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
      endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
      budget: budget,
      status: ProjectStatus.fromString(status),
      priority: _parsePriority(priority),
      ownerUserId: ownerUserId,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }

  /// Parsear prioridad que puede venir como int o String
  Priority _parsePriority(dynamic value) {
    if (value is int) {
      return Priority.fromValue(value);
    } else if (value is String) {
      return Priority.fromString(value);
    }
    return Priority.medium;
  }

  /// Crear desde entidad de dominio
  factory ProjectDto.fromEntity(Project project) {
    return ProjectDto(
      id: project.id,
      name: project.name,
      description: project.description,
      startDate: project.startDate?.toIso8601String().split('T').first,
      endDate: project.endDate?.toIso8601String().split('T').first,
      budget: project.budget,
      status: project.status.toApiString(),
      priority: project.priority.value,
      ownerUserId: project.ownerUserId,
      tasks: project.tasks.map((t) => TaskDto.fromEntity(t)).toList(),
    );
  }
}
