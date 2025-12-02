// lib/features/workers/data/models/worker_dto.dart

import '../../domain/entities/worker.dart';
import 'worker_assignment_simple_dto.dart';

/// DTO para Worker
class WorkerDto {
  final String id;
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;
  final List<WorkerAssignmentSimpleDto> assignments;

  WorkerDto({
    required this.id,
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
    this.assignments = const [],
  });

  /// Crea DTO desde JSON del servidor
  factory WorkerDto.fromJson(Map<String, dynamic> json) {
    return WorkerDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      documentNumber: json['documentNumber'] as String,
      phone: json['phone'] as String? ?? '',
      position: json['position'] as String? ?? '',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      assignments: (json['assignments'] as List<dynamic>?)
              ?.map((e) => WorkerAssignmentSimpleDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'documentNumber': documentNumber,
      'phone': phone,
      'position': position,
      'hourlyRate': hourlyRate,
      'assignments': assignments.map((e) => e.toJson()).toList(),
    };
  }

  /// Convierte a entidad de dominio
  Worker toEntity() {
    return Worker(
      id: id,
      fullName: fullName,
      documentNumber: documentNumber,
      phone: phone,
      position: position,
      hourlyRate: hourlyRate,
      assignments: assignments.map((e) => e.toEntity()).toList(),
    );
  }
}
