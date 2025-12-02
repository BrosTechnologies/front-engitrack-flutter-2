// lib/features/profile/data/models/update_profile_request_dto.dart

/// DTO para la petición de actualización de perfil
class UpdateProfileRequestDto {
  final String fullName;
  final String? phone;

  UpdateProfileRequestDto({
    required this.fullName,
    this.phone,
  });

  /// Convierte a JSON para enviar al servidor
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'fullName': fullName,
    };
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }
    return json;
  }
}
