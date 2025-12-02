// lib/features/projects/domain/enums/priority.dart

import 'package:flutter/material.dart';

/// Enum de prioridad de proyectos
/// Corresponde al enum Priority del backend
enum Priority {
  low,
  medium,
  high;

  /// Valor entero para enviar al API
  int get value {
    switch (this) {
      case Priority.low:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.high:
        return 2;
    }
  }

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Baja';
      case Priority.medium:
        return 'Media';
      case Priority.high:
        return 'Alta';
    }
  }

  /// Color asociado a la prioridad
  Color get color {
    switch (this) {
      case Priority.low:
        return const Color(0xFF4CAF50); // Verde
      case Priority.medium:
        return const Color(0xFFFF9800); // Naranja
      case Priority.high:
        return const Color(0xFFE53E3E); // Rojo
    }
  }

  /// Color de fondo (más claro)
  Color get backgroundColor {
    switch (this) {
      case Priority.low:
        return const Color(0xFFE8F5E9);
      case Priority.medium:
        return const Color(0xFFFFF3E0);
      case Priority.high:
        return const Color(0xFFFFEBEE);
    }
  }

  /// Icono asociado
  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }

  /// Crear desde valor entero del API
  static Priority fromValue(int value) {
    switch (value) {
      case 0:
        return Priority.low;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  /// Crear desde string del API
  static Priority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return Priority.low;
      case 'MEDIUM':
        return Priority.medium;
      case 'HIGH':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  /// Convertir a string para API
  String toApiString() {
    return name.toUpperCase();
  }
}
