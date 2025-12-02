// lib/features/projects/data/models/update_task_status_request_dto.dart

import '../../domain/enums/task_status.dart';

/// DTO para actualizar el estado de una tarea
class UpdateTaskStatusRequestDto {
  final String status;

  const UpdateTaskStatusRequestDto({
    required this.status,
  });

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }

  /// Factory para crear con TaskStatus
  factory UpdateTaskStatusRequestDto.fromStatus(TaskStatus status) {
    return UpdateTaskStatusRequestDto(
      status: status.toApiString(),
    );
  }
}
