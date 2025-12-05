// lib/features/calendar/presentation/pages/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/calendar_event_card.dart';

/// Página del Calendario
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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

  @override
  void initState() {
    super.initState();
    context.read<CalendarBloc>().add(const LoadCalendarDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calendario',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Ir al día de hoy
              final today = DateTime.now();
              context.read<CalendarBloc>().add(ChangeMonthEvent(today));
              context.read<CalendarBloc>().add(SelectDayEvent(today));
            },
            icon: const Icon(
              Icons.today,
              color: AppColors.primary,
            ),
            tooltip: 'Ir a hoy',
          ),
        ],
      ),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<CalendarBloc>().add(const ClearCalendarErrorEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.projects.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CalendarBloc>().add(const RefreshCalendarEvent());
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grid del calendario
                  CalendarGrid(
                    currentMonth: state.currentMonth,
                    selectedDay: state.selectedDay,
                    eventsByDay: state.eventsByDay,
                    onDaySelected: (day) {
                      context.read<CalendarBloc>().add(SelectDayEvent(day));
                    },
                    onMonthChanged: (month) {
                      context.read<CalendarBloc>().add(ChangeMonthEvent(month));
                    },
                  ),

                  // Sección de eventos del día seleccionado
                  _buildSelectedDayEvents(state),

                  // Espacio inferior para el BottomNav
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayEvents(CalendarState state) {
    final selectedDay = state.selectedDay;
    final events = state.selectedDayEvents;

    String dateTitle;
    if (selectedDay != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      if (selectedDay.isAtSameMomentAs(today)) {
        dateTitle = 'Hoy';
      } else if (selectedDay.isAtSameMomentAs(tomorrow)) {
        dateTitle = 'Mañana';
      } else {
        final monthName = _monthNames[selectedDay.month - 1];
        dateTitle = '${selectedDay.day} de $monthName';
      }
    } else {
      dateTitle = 'Selecciona un día';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (events.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length} ${events.length == 1 ? 'tarea' : 'tareas'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return CalendarEventCard(
                  event: event,
                  onTap: () {
                    // Navegar al proyecto
                    context.push('/projects/${event.projectId}');
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 56,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin tareas para este día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona otro día o crea nuevas tareas',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
