// lib/features/workers/domain/entities/project_worker.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa un worker asignado a un proyecto específico
/// Incluye información del worker + datos de la asignación
class ProjectWorker extends Equatable {
  /// ID del worker
  final String workerId;

  /// Nombre completo del worker
  final String fullName;

  /// Número de documento
  final String documentNumber;

  /// Teléfono del worker
  final String phone;

  /// Posición/cargo del worker
  final String position;

  /// Tarifa por hora
  final double hourlyRate;

  /// ID de la asignación
  final String assignmentId;

  /// Fecha de inicio de la asignación
  final DateTime startDate;

  /// Fecha de fin de la asignación
  final DateTime? endDate;

  const ProjectWorker({
    required this.workerId,
    required this.fullName,
    required this.documentNumber,
    this.phone = '',
    this.position = 'Colaborador',
    this.hourlyRate = 0.0,
    required this.assignmentId,
    required this.startDate,
    this.endDate,
  });

  /// Obtiene las iniciales del nombre
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Formatea la tarifa por hora como moneda
  String get formattedHourlyRate {
    if (hourlyRate == 0.0) return 'Sin tarifa';
    return 'S/ ${hourlyRate.toStringAsFixed(2)}/hora';
  }

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

  /// Estado de la asignación como texto
  String get statusText {
    if (isCompleted) return 'Finalizado';
    if (isActive) return 'Activo';
    return 'Pendiente';
  }

  /// Copia la entidad con valores modificados
  ProjectWorker copyWith({
    String? workerId,
    String? fullName,
    String? documentNumber,
    String? phone,
    String? position,
    double? hourlyRate,
    String? assignmentId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ProjectWorker(
      workerId: workerId ?? this.workerId,
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      assignmentId: assignmentId ?? this.assignmentId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
        workerId,
        fullName,
        documentNumber,
        phone,
        position,
        hourlyRate,
        assignmentId,
        startDate,
        endDate,
      ];
}
