// lib/features/workers/domain/entities/worker_assignment_simple.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa una asignación simple de worker a proyecto
/// Se usa dentro de la entidad Worker para mostrar sus asignaciones
class WorkerAssignmentSimple extends Equatable {
  /// ID único de la asignación
  final String id;

  /// ID del worker asignado
  final String workerId;

  /// ID del proyecto
  final String projectId;

  /// Fecha de inicio de la asignación
  final DateTime startDate;

  /// Fecha de fin de la asignación
  final DateTime? endDate;

  const WorkerAssignmentSimple({
    required this.id,
    required this.workerId,
    required this.projectId,
    required this.startDate,
    this.endDate,
  });

  /// Verifica si la asignación está activa actualmente
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

  /// Copia la entidad con valores modificados
  WorkerAssignmentSimple copyWith({
    String? id,
    String? workerId,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return WorkerAssignmentSimple(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [id, workerId, projectId, startDate, endDate];
}
