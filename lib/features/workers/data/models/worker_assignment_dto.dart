// lib/features/workers/data/models/worker_assignment_dto.dart

import '../../domain/entities/worker_assignment.dart';

/// DTO para asignación con información del proyecto
class WorkerAssignmentDto {
  final String assignmentId;
  final String projectId;
  final String projectName;
  final String startDate;
  final String? endDate;

  WorkerAssignmentDto({
    required this.assignmentId,
    required this.projectId,
    required this.projectName,
    required this.startDate,
    this.endDate,
  });

  /// Crea DTO desde JSON del servidor
  factory WorkerAssignmentDto.fromJson(Map<String, dynamic> json) {
    return WorkerAssignmentDto(
      assignmentId: json['assignmentId'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'projectId': projectId,
      'projectName': projectName,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
  }

  /// Convierte a entidad de dominio
  WorkerAssignment toEntity() {
    return WorkerAssignment(
      assignmentId: assignmentId,
      projectId: projectId,
      projectName: projectName,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
    );
  }
}
