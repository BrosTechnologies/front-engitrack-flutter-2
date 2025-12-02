// lib/features/workers/presentation/widgets/project_worker_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/project_worker.dart';

/// Widget card para mostrar un worker asignado a un proyecto
class ProjectWorkerCard extends StatelessWidget {
  /// Worker asignado
  final ProjectWorker worker;

  /// Callback cuando se toca el card
  final VoidCallback? onTap;

  /// Callback cuando se quiere remover el worker del proyecto
  final VoidCallback? onRemove;

  /// Si el card permite deslizar para eliminar
  final bool dismissible;

  const ProjectWorkerCard({
    super.key,
    required this.worker,
    this.onTap,
    this.onRemove,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar con iniciales
              _buildAvatar(),
              const SizedBox(width: 12),

              // Información del worker
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      worker.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Posición
                    Text(
                      worker.position,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Fechas de asignación
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateRange(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de estado
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );

    if (dismissible && onRemove != null) {
      return Dismissible(
        key: Key(worker.assignmentId),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: Text(
                    '¿Deseas remover a ${worker.fullName} de este proyecto?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Remover'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (direction) => onRemove?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_remove,
            color: Colors.white,
          ),
        ),
        child: card,
      );
    }

    return card;
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: _getStatusColor().withValues(alpha: 0.1),
      child: Text(
        worker.initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final label = _getStatusLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('dd MMM', 'es');
    final startStr = dateFormat.format(worker.startDate);

    if (worker.endDate != null) {
      final endStr = dateFormat.format(worker.endDate!);
      return '$startStr - $endStr';
    }

    return 'Desde $startStr';
  }

  Color _getStatusColor() {
    if (worker.isCompleted) return Colors.grey;
    if (worker.isActive) return AppColors.success;
    return AppColors.warning; // Pendiente
  }

  String _getStatusLabel() {
    if (worker.isCompleted) return 'Finalizado';
    if (worker.isActive) return 'Activo';
    return 'Pendiente';
  }
}
