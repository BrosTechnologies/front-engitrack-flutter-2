// lib/features/workers/data/models/assign_worker_request_dto.dart

import 'package:intl/intl.dart';

/// DTO para asignar un worker a un proyecto
class AssignWorkerRequestDto {
  final String workerId;
  final DateTime startDate;
  final DateTime? endDate;

  AssignWorkerRequestDto({
    required this.workerId,
    required this.startDate,
    this.endDate,
  });

  /// Convierte a JSON para el servidor
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      'workerId': workerId,
      'startDate': dateFormat.format(startDate),
      if (endDate != null) 'endDate': dateFormat.format(endDate!),
    };
  }
}
