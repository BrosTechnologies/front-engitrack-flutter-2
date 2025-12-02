// lib/features/workers/data/models/update_worker_request_dto.dart

/// DTO para actualizar un worker existente
class UpdateWorkerRequestDto {
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;

  UpdateWorkerRequestDto({
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
  });

  /// Convierte a JSON para el servidor
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'documentNumber': documentNumber,
      'phone': phone,
      'position': position,
      'hourlyRate': hourlyRate,
    };
  }
}
