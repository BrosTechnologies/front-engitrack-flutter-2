// lib/features/projects/data/models/create_project_request_dto.dart

import '../../domain/enums/priority.dart';
import 'create_task_request_dto.dart';

/// DTO para crear un proyecto
class CreateProjectRequestDto {
  final String name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final double? budget;
  final int priority;
  final String ownerUserId;
  final List<CreateTaskRequestDto>? tasks;

  const CreateProjectRequestDto({
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.budget,
    required this.priority,
    required this.ownerUserId,
    this.tasks,
  });

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (budget != null) 'budget': budget,
      'priority': priority,
      'ownerUserId': ownerUserId,
      if (tasks != null && tasks!.isNotEmpty)
        'tasks': tasks!.map((t) => t.toJson()).toList(),
    };
  }

  /// Factory para crear con tipos seguros
  factory CreateProjectRequestDto.create({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    required Priority priority,
    required String ownerUserId,
    List<CreateTaskRequestDto>? tasks,
  }) {
    return CreateProjectRequestDto(
      name: name,
      description: description,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      budget: budget,
      priority: priority.value,
      ownerUserId: ownerUserId,
      tasks: tasks,
    );
  }
}
