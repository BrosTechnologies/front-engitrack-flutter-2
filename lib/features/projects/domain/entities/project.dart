// lib/features/projects/domain/entities/project.dart

import 'package:equatable/equatable.dart';
import '../enums/priority.dart';
import '../enums/project_status.dart';
import 'task.dart';

/// Entidad de dominio para Proyecto
/// Representa un proyecto con sus tareas
class Project extends Equatable {
  /// ID único del proyecto
  final String id;

  /// Nombre del proyecto
  final String name;

  /// Descripción del proyecto
  final String? description;

  /// Fecha de inicio
  final DateTime? startDate;

  /// Fecha de fin
  final DateTime? endDate;

  /// Presupuesto del proyecto
  final double? budget;

  /// Estado del proyecto
  final ProjectStatus status;

  /// Prioridad del proyecto
  final Priority priority;

  /// ID del usuario propietario
  final String ownerUserId;

  /// Lista de tareas del proyecto
  final List<Task> tasks;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.budget,
    required this.status,
    required this.priority,
    required this.ownerUserId,
    this.tasks = const [],
  });

  /// Número total de tareas
  int get totalTasks => tasks.length;

  /// Número de tareas completadas
  int get completedTasks => tasks.where((t) => t.isCompleted).length;

  /// Número de tareas pendientes
  int get pendingTasks => tasks.where((t) => t.isPending).length;

  /// Número de tareas en progreso
  int get inProgressTasks => tasks.where((t) => t.isInProgress).length;

  /// Porcentaje de progreso (0.0 - 1.0)
  double get progress {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Porcentaje de progreso como entero (0 - 100)
  int get progressPercentage => (progress * 100).round();

  /// Verifica si el proyecto está completado
  bool get isCompleted => status == ProjectStatus.completed;

  /// Verifica si el proyecto está activo
  bool get isActive => status == ProjectStatus.active;

  /// Verifica si el proyecto está pausado
  bool get isPaused => status == ProjectStatus.paused;

  /// Verifica si hay tareas vencidas
  bool get hasOverdueTasks => tasks.any((t) => t.isOverdue);

  /// Número de días restantes hasta fecha fin
  int? get daysRemaining {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }

  /// Duración total del proyecto en días
  int? get durationInDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays;
  }

  /// Verifica si el proyecto está vencido
  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && !isCompleted;
  }

  /// Copia con modificaciones
  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    ProjectStatus? status,
    Priority? priority,
    String? ownerUserId,
    List<Task>? tasks,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        budget,
        status,
        priority,
        ownerUserId,
        tasks,
      ];
}
