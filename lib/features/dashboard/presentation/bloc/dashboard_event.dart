// lib/features/dashboard/presentation/bloc/dashboard_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del DashboardBloc
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar datos del dashboard
class LoadDashboardDataEvent extends DashboardEvent {
  const LoadDashboardDataEvent();
}

/// Refrescar datos del dashboard
class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}

/// Toggle estado de una tarea
class ToggleTaskStatusEvent extends DashboardEvent {
  final String projectId;
  final String taskId;

  const ToggleTaskStatusEvent({
    required this.projectId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [projectId, taskId];
}

/// Limpiar mensaje de error
class ClearDashboardErrorEvent extends DashboardEvent {
  const ClearDashboardErrorEvent();
}
