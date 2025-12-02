// lib/features/profile/data/models/user_stats_dto.dart

import '../../domain/entities/user_stats.dart';

/// DTO para UserStats
class UserStatsDto {
  final int projectsCount;
  final int tasksCount;
  final int completedTasksCount;

  UserStatsDto({
    this.projectsCount = 0,
    this.tasksCount = 0,
    this.completedTasksCount = 0,
  });

  /// Crea DTO desde JSON del servidor
  factory UserStatsDto.fromJson(Map<String, dynamic> json) {
    return UserStatsDto(
      projectsCount: json['projectsCount'] as int? ?? 0,
      tasksCount: json['tasksCount'] as int? ?? 0,
      completedTasksCount: json['completedTasksCount'] as int? ?? 0,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'projectsCount': projectsCount,
      'tasksCount': tasksCount,
      'completedTasksCount': completedTasksCount,
    };
  }

  /// Convierte a entidad de dominio
  UserStats toEntity() {
    return UserStats(
      projectsCount: projectsCount,
      tasksCount: tasksCount,
      completedTasksCount: completedTasksCount,
    );
  }

  /// Crea DTO desde entidad
  factory UserStatsDto.fromEntity(UserStats entity) {
    return UserStatsDto(
      projectsCount: entity.projectsCount,
      tasksCount: entity.tasksCount,
      completedTasksCount: entity.completedTasksCount,
    );
  }
}
