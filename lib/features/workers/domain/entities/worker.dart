// lib/features/workers/domain/entities/worker.dart

import 'package:equatable/equatable.dart';
import 'worker_assignment_simple.dart';

/// Entidad que representa un worker (colaborador/trabajador)
class Worker extends Equatable {
  /// ID único del worker
  final String id;

  /// Nombre completo del worker
  final String fullName;

  /// Número de documento de identidad
  final String documentNumber;

  /// Número de teléfono
  final String phone;

  /// Posición o cargo del worker
  final String position;

  /// Tarifa por hora de trabajo
  final double hourlyRate;

  /// Lista de asignaciones a proyectos
  final List<WorkerAssignmentSimple> assignments;

  const Worker({
    required this.id,
    required this.fullName,
    required this.documentNumber,
    required this.phone,
    required this.position,
    required this.hourlyRate,
    this.assignments = const [],
  });

  /// Obtiene las iniciales del nombre (máximo 2 letras)
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Formatea la tarifa por hora como moneda
  String get formattedHourlyRate {
    return 'S/ ${hourlyRate.toStringAsFixed(2)}/hora';
  }

  /// Número de proyectos activos asignados
  int get activeAssignmentsCount {
    return assignments.where((a) => a.isActive).length;
  }

  /// Verifica si el worker tiene asignaciones activas
  bool get hasActiveAssignments => activeAssignmentsCount > 0;

  /// Obtiene la descripción corta del worker
  String get shortDescription {
    if (position.isNotEmpty) {
      return position;
    }
    return 'Colaborador';
  }

  /// Copia la entidad con valores modificados
  Worker copyWith({
    String? id,
    String? fullName,
    String? documentNumber,
    String? phone,
    String? position,
    double? hourlyRate,
    List<WorkerAssignmentSimple>? assignments,
  }) {
    return Worker(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      assignments: assignments ?? this.assignments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        documentNumber,
        phone,
        position,
        hourlyRate,
        assignments,
      ];
}
