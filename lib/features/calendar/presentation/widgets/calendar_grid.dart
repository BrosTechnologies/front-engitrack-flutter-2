// lib/features/calendar/presentation/widgets/calendar_grid.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../projects/domain/enums/priority.dart';
import '../bloc/calendar_state.dart';

/// Widget del grid del calendario mensual
class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDay;
  final Map<DateTime, List<CalendarEventItem>> eventsByDay;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onMonthChanged;

  // Nombres de días en español
  static const List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  // Nombres de meses en español
  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekDaysHeader(),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName = _monthNames[currentMonth.month - 1];
    final year = currentMonth.year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              final previousMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
                1,
              );
              onMonthChanged(previousMonth);
            },
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$monthName $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
                1,
              );
              onMonthChanged(nextMonth);
            },
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = _getDaysInMonth();
    final firstDayWeekday = _getFirstDayWeekday();
    final totalCells = daysInMonth + firstDayWeekday;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - firstDayWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }

              return Expanded(
                child: _buildDayCell(dayNumber),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(int dayNumber) {
    final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
    final isToday = _isToday(cellDate);
    final isSelected = _isSelected(cellDate);
    final events = eventsByDay[cellDate] ?? [];
    final hasEvents = events.isNotEmpty;

    return GestureDetector(
      onTap: () => onDaySelected(cellDate),
      child: Container(
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppColors.primary
                        : AppColors.textPrimary,
              ),
            ),
            if (hasEvents) ...[
              const SizedBox(height: 2),
              _buildEventIndicators(events, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventIndicators(List<CalendarEventItem> events, bool isSelected) {
    // Mostrar máximo 3 indicadores
    final displayEvents = events.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayEvents.map((event) {
        Color indicatorColor;
        switch (event.projectPriority) {
          case Priority.high:
            indicatorColor = isSelected ? Colors.white : AppColors.priorityHigh;
            break;
          case Priority.medium:
            indicatorColor = isSelected ? Colors.white : AppColors.priorityMedium;
            break;
          case Priority.low:
            indicatorColor = isSelected ? Colors.white : AppColors.priorityLow;
            break;
        }

        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  int _getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  int _getFirstDayWeekday() {
    // Ajustar para que Lunes sea 0 y Domingo sea 6
    final weekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    return weekday - 1; // weekday es 1=Lunes, 7=Domingo
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    if (selectedDay == null) return false;
    return date.year == selectedDay!.year &&
        date.month == selectedDay!.month &&
        date.day == selectedDay!.day;
  }
}
