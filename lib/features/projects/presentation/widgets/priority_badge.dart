// lib/features/projects/presentation/widgets/priority_badge.dart

import 'package:flutter/material.dart';
import '../../domain/enums/priority.dart';

/// Widget badge para mostrar la prioridad de un proyecto
class PriorityBadge extends StatelessWidget {
  /// Prioridad a mostrar
  final Priority priority;

  /// Si debe mostrar el icono
  final bool showIcon;

  /// Tamaño del badge
  final BadgeSize size;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              priority.icon,
              size: _iconSize,
              color: priority.color,
            ),
            SizedBox(width: _spacing),
          ],
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }

  double get _horizontalPadding {
    switch (size) {
      case BadgeSize.small:
        return 6;
      case BadgeSize.medium:
        return 8;
      case BadgeSize.large:
        return 12;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case BadgeSize.small:
        return 2;
      case BadgeSize.medium:
        return 4;
      case BadgeSize.large:
        return 6;
    }
  }

  double get _borderRadius {
    switch (size) {
      case BadgeSize.small:
        return 4;
      case BadgeSize.medium:
        return 6;
      case BadgeSize.large:
        return 8;
    }
  }

  double get _iconSize {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 14;
      case BadgeSize.large:
        return 18;
    }
  }

  double get _fontSize {
    switch (size) {
      case BadgeSize.small:
        return 10;
      case BadgeSize.medium:
        return 12;
      case BadgeSize.large:
        return 14;
    }
  }

  double get _spacing {
    switch (size) {
      case BadgeSize.small:
        return 2;
      case BadgeSize.medium:
        return 4;
      case BadgeSize.large:
        return 6;
    }
  }
}

/// Tamaños disponibles para el badge
enum BadgeSize { small, medium, large }
