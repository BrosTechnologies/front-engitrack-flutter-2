// lib/features/calendar/presentation/bloc/calendar_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// Bloc para manejar el estado del Calendario
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ProjectRepository _projectRepository;

  CalendarBloc(this._projectRepository) : super(CalendarState.initial()) {
    on<LoadCalendarDataEvent>(_onLoadCalendarData);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<SelectDayEvent>(_onSelectDay);
    on<RefreshCalendarEvent>(_onRefreshCalendar);
    on<ClearCalendarErrorEvent>(_onClearError);
  }

  Future<void> _onLoadCalendarData(
    LoadCalendarDataEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _projectRepository.getProjects();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (projects) {
        final eventsByDay = _buildEventsByDay(projects);
        final selectedDayEvents = _getEventsForDay(
          state.selectedDay ?? DateTime.now(),
          eventsByDay,
        );

        emit(state.copyWith(
          isLoading: false,
          projects: projects,
          eventsByDay: eventsByDay,
          selectedDayEvents: selectedDayEvents,
        ));
      },
    );
  }

  void _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(
      currentMonth: DateTime(event.newMonth.year, event.newMonth.month, 1),
    ));
  }

  void _onSelectDay(
    SelectDayEvent event,
    Emitter<CalendarState> emit,
  ) {
    final normalizedDay = DateTime(
      event.selectedDay.year,
      event.selectedDay.month,
      event.selectedDay.day,
    );

    final selectedDayEvents = _getEventsForDay(normalizedDay, state.eventsByDay);

    emit(state.copyWith(
      selectedDay: normalizedDay,
      selectedDayEvents: selectedDayEvents,
    ));
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final result = await _projectRepository.getProjects();

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (projects) {
        final eventsByDay = _buildEventsByDay(projects);
        final selectedDayEvents = state.selectedDay != null
            ? _getEventsForDay(state.selectedDay!, eventsByDay)
            : <CalendarEventItem>[];

        emit(state.copyWith(
          projects: projects,
          eventsByDay: eventsByDay,
          selectedDayEvents: selectedDayEvents,
        ));
      },
    );
  }

  void _onClearError(
    ClearCalendarErrorEvent event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  /// Construye un mapa de eventos por día
  Map<DateTime, List<CalendarEventItem>> _buildEventsByDay(List<dynamic> projects) {
    final Map<DateTime, List<CalendarEventItem>> eventsByDay = {};

    for (final project in projects) {
      for (final task in project.tasks) {
        if (task.dueDate != null) {
          final normalizedDate = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );

          final eventItem = CalendarEventItem(
            task: task,
            projectId: project.id,
            projectName: project.name,
            projectPriority: project.priority,
          );

          if (eventsByDay.containsKey(normalizedDate)) {
            eventsByDay[normalizedDate]!.add(eventItem);
          } else {
            eventsByDay[normalizedDate] = [eventItem];
          }
        }
      }
    }

    return eventsByDay;
  }

  /// Obtiene los eventos para un día específico
  List<CalendarEventItem> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<CalendarEventItem>> eventsByDay,
  ) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return eventsByDay[normalizedDay] ?? [];
  }
}
