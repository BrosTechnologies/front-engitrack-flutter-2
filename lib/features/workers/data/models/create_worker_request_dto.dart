// lib/features/workers/data/models/create_worker_request_dto.dart

/// DTO para crear un nuevo worker
class CreateWorkerRequestDto {
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;

  CreateWorkerRequestDto({
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
