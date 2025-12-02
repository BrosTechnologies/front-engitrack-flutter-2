// lib/features/workers/presentation/widgets/assign_worker_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/worker.dart';

/// Dialog para asignar un worker a un proyecto con fechas
class AssignWorkerDialog extends StatefulWidget {
  /// Worker a asignar
  final Worker worker;

  /// Fecha límite del proyecto (opcional)
  final DateTime? projectEndDate;

  /// Callback cuando se confirma la asignación
  final void Function(DateTime startDate, DateTime? endDate) onConfirm;

  const AssignWorkerDialog({
    super.key,
    required this.worker,
    this.projectEndDate,
    required this.onConfirm,
  });

  /// Muestra el dialog y retorna true si se confirmó
  static Future<bool?> show(
    BuildContext context, {
    required Worker worker,
    DateTime? projectEndDate,
    required void Function(DateTime startDate, DateTime? endDate) onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AssignWorkerDialog(
        worker: worker,
        projectEndDate: projectEndDate,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AssignWorkerDialog> createState() => _AssignWorkerDialogState();
}

class _AssignWorkerDialogState extends State<AssignWorkerDialog> {
  late DateTime _startDate;
  DateTime? _endDate;
  final _dateFormat = DateFormat('dd/MM/yyyy', 'es');

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar trabajador'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del worker
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      widget.worker.initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.worker.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.worker.position,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fecha de inicio
            const Text(
              'Fecha de inicio *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, isStartDate: true),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _dateFormat.format(_startDate),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mostrar fecha límite del proyecto si existe
            if (widget.projectEndDate != null) ...[  
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fecha límite del proyecto: ${_dateFormat.format(widget.projectEndDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fecha de fin (opcional)
            const Text(
              'Fecha de fin (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, isStartDate: false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 20,
                      color: _endDate != null
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _endDate != null
                            ? _dateFormat.format(_endDate!)
                            : 'Sin fecha de fin',
                        style: TextStyle(
                          fontSize: 15,
                          color: _endDate != null
                              ? AppColors.textPrimary
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    if (_endDate != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _endDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.grey.shade500,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_startDate, _endDate);
            Navigator.of(context).pop(true);
          },
          child: const Text('Asignar'),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calcular fecha máxima (fecha límite del proyecto o 2030 si no hay)
    final maxDate = widget.projectEndDate ?? DateTime(2030);
    
    final initialDate = isStartDate
        ? _startDate
        : (_endDate ?? _startDate.add(const Duration(days: 30)));

    // Fecha de inicio: desde hoy hasta la fecha límite del proyecto
    // Fecha de fin: desde la fecha de inicio hasta la fecha límite del proyecto
    final firstDate = isStartDate ? today : _startDate;
    final lastDate = maxDate;

    // Asegurar que initialDate no exceda lastDate
    final adjustedInitialDate = initialDate.isAfter(lastDate) 
        ? lastDate 
        : (initialDate.isBefore(firstDate) ? firstDate : initialDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: adjustedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Si la fecha de fin es anterior a la de inicio, limpiarla
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
