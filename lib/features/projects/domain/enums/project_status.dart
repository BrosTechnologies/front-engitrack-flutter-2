// lib/features/projects/domain/enums/project_status.dart

import 'package:flutter/material.dart';

/// Enum de estado de proyectos
/// Corresponde al enum ProjectStatus del backend
enum ProjectStatus {
  active,
  paused,
  completed;

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'En curso';
      case ProjectStatus.paused:
        return 'Pausado';
      case ProjectStatus.completed:
        return 'Completado';
    }
  }

  /// Color asociado al estado
  Color get color {
    switch (this) {
      case ProjectStatus.active:
        return const Color(0xFF007AFF); // Azul
      case ProjectStatus.paused:
        return const Color(0xFF9E9E9E); // Gris
      case ProjectStatus.completed:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  /// Color de fondo (más claro)
  Color get backgroundColor {
    switch (this) {
      case ProjectStatus.active:
        return const Color(0xFFE3F2FD);
      case ProjectStatus.paused:
        return const Color(0xFFF5F5F5);
      case ProjectStatus.completed:
        return const Color(0xFFE8F5E9);
    }
  }

  /// Icono asociado
  IconData get icon {
    switch (this) {
      case ProjectStatus.active:
        return Icons.play_circle_outline;
      case ProjectStatus.paused:
        return Icons.pause_circle_outline;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  /// Crear desde string del API
  static ProjectStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return ProjectStatus.active;
      case 'PAUSED':
        return ProjectStatus.paused;
      case 'COMPLETED':
        return ProjectStatus.completed;
      default:
        return ProjectStatus.active;
    }
  }

  /// Convertir a string para API
  String toApiString() {
    return name.toUpperCase();
  }
}
