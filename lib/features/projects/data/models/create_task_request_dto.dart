// lib/features/projects/data/models/create_task_request_dto.dart

/// DTO para crear una tarea
class CreateTaskRequestDto {
  final String title;
  final String? dueDate;

  const CreateTaskRequestDto({
    required this.title,
    this.dueDate,
  });

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (dueDate != null) 'dueDate': dueDate,
    };
  }

  /// Crear desde fecha DateTime
  factory CreateTaskRequestDto.create({
    required String title,
    DateTime? dueDate,
  }) {
    return CreateTaskRequestDto(
      title: title,
      dueDate: dueDate?.toIso8601String().split('T').first,
    );
  }
}
