// lib/features/workers/presentation/bloc/worker_assignments/worker_assignments_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/worker_assignment.dart';

/// Estados del bloc de asignaciones de worker
abstract class WorkerAssignmentsState extends Equatable {
  const WorkerAssignmentsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkerAssignmentsInitial extends WorkerAssignmentsState {
  const WorkerAssignmentsInitial();
}

/// Estado de carga
class WorkerAssignmentsLoading extends WorkerAssignmentsState {
  const WorkerAssignmentsLoading();
}

/// Estado con datos cargados
class WorkerAssignmentsLoaded extends WorkerAssignmentsState {
  final List<WorkerAssignment> assignments;
  final List<WorkerAssignment> activeAssignments;
  final List<WorkerAssignment> completedAssignments;
  final List<WorkerAssignment> pendingAssignments;

  const WorkerAssignmentsLoaded({
    required this.assignments,
    required this.activeAssignments,
    required this.completedAssignments,
    required this.pendingAssignments,
  });

  factory WorkerAssignmentsLoaded.fromAssignments(
    List<WorkerAssignment> assignments,
  ) {
    final active = assignments.where((a) => a.isActive).toList();
    final completed = assignments.where((a) => a.isCompleted).toList();
    final pending = assignments.where((a) => a.isPending).toList();

    return WorkerAssignmentsLoaded(
      assignments: assignments,
      activeAssignments: active,
      completedAssignments: completed,
      pendingAssignments: pending,
    );
  }

  @override
  List<Object?> get props => [
        assignments,
        activeAssignments,
        completedAssignments,
        pendingAssignments,
      ];
}

/// Estado de error
class WorkerAssignmentsError extends WorkerAssignmentsState {
  final String message;

  const WorkerAssignmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
