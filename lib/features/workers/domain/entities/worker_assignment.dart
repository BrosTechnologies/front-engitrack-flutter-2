// lib/features/workers/domain/entities/worker_assignment.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa una asignación de worker con información del proyecto
/// Se usa para mostrar las asignaciones de un worker específico
class WorkerAssignment extends Equatable {
  /// ID de la asignación
  final String assignmentId;

  /// ID del proyecto
  final String projectId;

  /// Nombre del proyecto
  final String projectName;

  /// Fecha de inicio de la asignación
  final DateTime startDate;

  /// Fecha de fin de la asignación
  final DateTime? endDate;

  const WorkerAssignment({
    required this.assignmentId,
    required this.projectId,
    required this.projectName,
    required this.startDate,
    this.endDate,
  });

  /// Verifica si la asignación está activa
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (today.isBefore(startDate)) return false;
    if (endDate != null && today.isAfter(endDate!)) return false;
    
    return true;
  }

  /// Verifica si la asignación ya terminó
  bool get isCompleted {
    if (endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(endDate!);
  }

  /// Verifica si la asignación aún no ha comenzado
  bool get isPending {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isBefore(startDate);
  }

  /// Estado de la asignación como texto
  String get statusText {
    if (isCompleted) return 'Finalizado';
    if (isActive) return 'Activo';
    return 'Próximo';
  }

  /// Calcula los días restantes de la asignación
  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (today.isAfter(endDate!)) return 0;
    
    return endDate!.difference(today).inDays;
  }

  /// Copia la entidad con valores modificados
  WorkerAssignment copyWith({
    String? assignmentId,
    String? projectId,
    String? projectName,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return WorkerAssignment(
      assignmentId: assignmentId ?? this.assignmentId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        assignmentId,
        projectId,
        projectName,
        startDate,
        endDate,
      ];
}
