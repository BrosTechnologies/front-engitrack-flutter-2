// lib/features/projects/domain/enums/task_status.dart

import 'package:flutter/material.dart';

/// Enum de estado de tareas
/// Corresponde al enum TaskStatus del backend
enum TaskStatus {
  pending,
  inProgress,
  done;

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En progreso';
      case TaskStatus.done:
        return 'Completada';
    }
  }

  /// Color asociado al estado
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFF9E9E9E); // Gris
      case TaskStatus.inProgress:
        return const Color(0xFF007AFF); // Azul
      case TaskStatus.done:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  /// Color de fondo (más claro)
  Color get backgroundColor {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFF5F5F5);
      case TaskStatus.inProgress:
        return const Color(0xFFE3F2FD);
      case TaskStatus.done:
        return const Color(0xFFE8F5E9);
    }
  }

  /// Icono asociado
  IconData get icon {
    switch (this) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  /// Crear desde string del API
  static TaskStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return TaskStatus.pending;
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      default:
        return TaskStatus.pending;
    }
  }

  /// Convertir a string para API
  String toApiString() {
    switch (this) {
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  /// Obtener el siguiente estado (para ciclar)
  TaskStatus get nextStatus {
    switch (this) {
      case TaskStatus.pending:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.done;
      case TaskStatus.done:
        return TaskStatus.pending;
    }
  }
}
