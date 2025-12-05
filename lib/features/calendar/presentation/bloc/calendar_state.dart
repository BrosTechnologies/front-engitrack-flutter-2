// lib/features/calendar/presentation/bloc/calendar_state.dart

import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/task.dart';
import '../../../projects/domain/enums/priority.dart';

/// Estado del BLoC de Calendar
class CalendarState extends Equatable {
  /// Indica si está cargando datos
  final bool isLoading;

  /// Mes actualmente mostrado
  final DateTime currentMonth;

  /// Día seleccionado (puede ser null si no hay selección)
  final DateTime? selectedDay;

  /// Lista de proyectos con sus tareas
  final List<Project> projects;

  /// Eventos del día seleccionado
  final List<CalendarEventItem> selectedDayEvents;

  /// Mapa de días con eventos (para marcar en el calendario)
  final Map<DateTime, List<CalendarEventItem>> eventsByDay;

  /// Mensaje de error
  final String? errorMessage;

  const CalendarState({
    this.isLoading = false,
    required this.currentMonth,
    this.selectedDay,
    this.projects = const [],
    this.selectedDayEvents = const [],
    this.eventsByDay = const {},
    this.errorMessage,
  });

  /// Estado inicial
  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      currentMonth: DateTime(now.year, now.month, 1),
      selectedDay: DateTime(now.year, now.month, now.day),
    );
  }

  CalendarState copyWith({
    bool? isLoading,
    DateTime? currentMonth,
    DateTime? selectedDay,
    List<Project>? projects,
    List<CalendarEventItem>? selectedDayEvents,
    Map<DateTime, List<CalendarEventItem>>? eventsByDay,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedDay = false,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      projects: projects ?? this.projects,
      selectedDayEvents: selectedDayEvents ?? this.selectedDayEvents,
      eventsByDay: eventsByDay ?? this.eventsByDay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        currentMonth,
        selectedDay,
        projects,
        selectedDayEvents,
        eventsByDay,
        errorMessage,
      ];
}

/// Representa un evento en el calendario (tarea con contexto de proyecto)
class CalendarEventItem extends Equatable {
  final Task task;
  final String projectId;
  final String projectName;
  final Priority projectPriority;

  const CalendarEventItem({
    required this.task,
    required this.projectId,
    required this.projectName,
    required this.projectPriority,
  });

  @override
  List<Object?> get props => [task, projectId, projectName, projectPriority];
}
