// lib/features/calendar/presentation/bloc/calendar_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Calendar
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los datos del calendario
class LoadCalendarDataEvent extends CalendarEvent {
  const LoadCalendarDataEvent();
}

/// Evento para cambiar el mes mostrado
class ChangeMonthEvent extends CalendarEvent {
  final DateTime newMonth;

  const ChangeMonthEvent(this.newMonth);

  @override
  List<Object?> get props => [newMonth];
}

/// Evento para seleccionar un día específico
class SelectDayEvent extends CalendarEvent {
  final DateTime selectedDay;

  const SelectDayEvent(this.selectedDay);

  @override
  List<Object?> get props => [selectedDay];
}

/// Evento para refrescar los datos del calendario
class RefreshCalendarEvent extends CalendarEvent {
  const RefreshCalendarEvent();
}

/// Evento para limpiar errores
class ClearCalendarErrorEvent extends CalendarEvent {
  const ClearCalendarErrorEvent();
}
