// lib/features/workers/data/models/worker_assignment_simple_dto.dart

import '../../domain/entities/worker_assignment_simple.dart';

/// DTO para asignación simple de worker
class WorkerAssignmentSimpleDto {
  final String id;
  final String workerId;
  final String projectId;
  final String startDate;
  final String? endDate;

  WorkerAssignmentSimpleDto({
    required this.id,
    required this.workerId,
    required this.projectId,
    required this.startDate,
    this.endDate,
  });

  /// Crea DTO desde JSON del servidor
  factory WorkerAssignmentSimpleDto.fromJson(Map<String, dynamic> json) {
    return WorkerAssignmentSimpleDto(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      projectId: json['projectId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workerId': workerId,
      'projectId': projectId,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
  }

  /// Convierte a entidad de dominio
  WorkerAssignmentSimple toEntity() {
    return WorkerAssignmentSimple(
      id: id,
      workerId: workerId,
      projectId: projectId,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
    );
  }
}
