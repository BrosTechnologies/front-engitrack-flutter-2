// lib/features/profile/domain/entities/user_stats.dart

import 'package:equatable/equatable.dart';

/// Entidad que representa las estadísticas del usuario
class UserStats extends Equatable {
  /// Cantidad de proyectos del usuario
  final int projectsCount;

  /// Cantidad total de tareas
  final int tasksCount;

  /// Cantidad de tareas completadas
  final int completedTasksCount;

  const UserStats({
    this.projectsCount = 0,
    this.tasksCount = 0,
    this.completedTasksCount = 0,
  });

  /// Porcentaje de tareas completadas
  double get completionPercentage {
    if (tasksCount == 0) return 0;
    return (completedTasksCount / tasksCount) * 100;
  }

  /// Porcentaje formateado como string
  String get formattedCompletionPercentage {
    return '${completionPercentage.toStringAsFixed(0)}%';
  }

  /// Tareas pendientes
  int get pendingTasksCount => tasksCount - completedTasksCount;

  /// Estadísticas vacías por defecto
  static const empty = UserStats();

  /// Copia con nuevos valores
  UserStats copyWith({
    int? projectsCount,
    int? tasksCount,
    int? completedTasksCount,
  }) {
    return UserStats(
      projectsCount: projectsCount ?? this.projectsCount,
      tasksCount: tasksCount ?? this.tasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
    );
  }

  @override
  List<Object> get props => [projectsCount, tasksCount, completedTasksCount];
}
