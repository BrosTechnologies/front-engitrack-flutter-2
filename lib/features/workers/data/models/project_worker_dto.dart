// lib/features/workers/data/models/project_worker_dto.dart

import '../../domain/entities/project_worker.dart';

/// DTO para ProjectWorker (worker asignado a un proyecto específico)
class ProjectWorkerDto {
  final String assignmentId;
  final String workerId;
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;
  final String startDate;
  final String? endDate;

  ProjectWorkerDto({
    required this.assignmentId,
    required this.workerId,
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
    required this.startDate,
    this.endDate,
  });

  /// Crea DTO desde JSON del servidor
  factory ProjectWorkerDto.fromJson(Map<String, dynamic> json) {
    return ProjectWorkerDto(
      assignmentId: json['assignmentId'] as String,
      workerId: json['workerId'] as String,
      fullName: json['fullName'] as String,
      documentNumber: json['documentNumber'] as String,
      phone: json['phone'] as String? ?? '',
      position: json['position'] as String? ?? 'Colaborador',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'workerId': workerId,
      'fullName': fullName,
      'documentNumber': documentNumber,
      'phone': phone,
      'position': position,
      'hourlyRate': hourlyRate,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
  }

  /// Convierte a entidad de dominio
  ProjectWorker toEntity() {
    return ProjectWorker(
      assignmentId: assignmentId,
      workerId: workerId,
      fullName: fullName,
      documentNumber: documentNumber,
      phone: phone,
      position: position,
      hourlyRate: hourlyRate,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
    );
  }
}
