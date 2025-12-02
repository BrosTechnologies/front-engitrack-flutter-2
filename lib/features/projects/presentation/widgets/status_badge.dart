// lib/features/projects/presentation/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/task_status.dart';

/// Widget badge para mostrar el estado de un proyecto
class ProjectStatusBadge extends StatelessWidget {
  /// Estado del proyecto
  final ProjectStatus status;

  /// Si debe mostrar el icono
  final bool showIcon;

  /// Tamaño del badge
  final StatusBadgeSize size;

  const ProjectStatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.size = StatusBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: _iconSize,
              color: status.color,
            ),
            SizedBox(width: _spacing),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  double get _horizontalPadding {
    switch (size) {
      case StatusBadgeSize.small:
        return 6;
      case StatusBadgeSize.medium:
        return 10;
      case StatusBadgeSize.large:
        return 14;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case StatusBadgeSize.small:
        return 2;
      case StatusBadgeSize.medium:
        return 4;
      case StatusBadgeSize.large:
        return 6;
    }
  }

  double get _borderRadius {
    switch (size) {
      case StatusBadgeSize.small:
        return 4;
      case StatusBadgeSize.medium:
        return 16;
      case StatusBadgeSize.large:
        return 20;
    }
  }

  double get _iconSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 12;
      case StatusBadgeSize.medium:
        return 14;
      case StatusBadgeSize.large:
        return 18;
    }
  }

  double get _fontSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 10;
      case StatusBadgeSize.medium:
        return 12;
      case StatusBadgeSize.large:
        return 14;
    }
  }

  double get _spacing {
    switch (size) {
      case StatusBadgeSize.small:
        return 2;
      case StatusBadgeSize.medium:
        return 4;
      case StatusBadgeSize.large:
        return 6;
    }
  }
}

/// Widget badge para mostrar el estado de una tarea
class TaskStatusBadge extends StatelessWidget {
  /// Estado de la tarea
  final TaskStatus status;

  /// Si debe mostrar el icono
  final bool showIcon;

  /// Tamaño del badge
  final StatusBadgeSize size;

  const TaskStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.size = StatusBadgeSize.small,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: _iconSize,
              color: status.color,
            ),
            SizedBox(width: _spacing),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  double get _horizontalPadding {
    switch (size) {
      case StatusBadgeSize.small:
        return 6;
      case StatusBadgeSize.medium:
        return 8;
      case StatusBadgeSize.large:
        return 12;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case StatusBadgeSize.small:
        return 2;
      case StatusBadgeSize.medium:
        return 4;
      case StatusBadgeSize.large:
        return 6;
    }
  }

  double get _borderRadius {
    switch (size) {
      case StatusBadgeSize.small:
        return 4;
      case StatusBadgeSize.medium:
        return 6;
      case StatusBadgeSize.large:
        return 8;
    }
  }

  double get _iconSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 12;
      case StatusBadgeSize.medium:
        return 14;
      case StatusBadgeSize.large:
        return 18;
    }
  }

  double get _fontSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 10;
      case StatusBadgeSize.medium:
        return 12;
      case StatusBadgeSize.large:
        return 14;
    }
  }

  double get _spacing {
    switch (size) {
      case StatusBadgeSize.small:
        return 2;
      case StatusBadgeSize.medium:
        return 4;
      case StatusBadgeSize.large:
        return 6;
    }
  }
}

/// Tamaños disponibles para el badge de estado
enum StatusBadgeSize { small, medium, large }
