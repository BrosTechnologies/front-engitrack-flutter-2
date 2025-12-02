// lib/features/projects/data/models/update_project_request_dto.dart

import '../../domain/enums/priority.dart';

/// DTO para actualizar un proyecto
class UpdateProjectRequestDto {
  final String? name;
  final String? description;
  final double? budget;
  final String? endDate;
  final int? priority;

  const UpdateProjectRequestDto({
    this.name,
    this.description,
    this.budget,
    this.endDate,
    this.priority,
  });

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (budget != null) json['budget'] = budget;
    if (endDate != null) json['endDate'] = endDate;
    if (priority != null) json['priority'] = priority;
    
    return json;
  }

  /// Factory para crear con tipos seguros
  factory UpdateProjectRequestDto.create({
    String? name,
    String? description,
    double? budget,
    DateTime? endDate,
    Priority? priority,
  }) {
    return UpdateProjectRequestDto(
      name: name,
      description: description,
      budget: budget,
      endDate: endDate?.toIso8601String().split('T').first,
      priority: priority?.value,
    );
  }

  /// Verifica si hay al menos un campo para actualizar
  bool get hasChanges {
    return name != null ||
        description != null ||
        budget != null ||
        endDate != null ||
        priority != null;
  }
}
