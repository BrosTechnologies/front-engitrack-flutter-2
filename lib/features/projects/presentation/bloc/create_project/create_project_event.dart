// lib/features/projects/presentation/bloc/create_project/create_project_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/enums/priority.dart';
import '../../../domain/repositories/project_repository.dart';

/// Eventos del bloc de crear proyecto
abstract class CreateProjectEvent extends Equatable {
  const CreateProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Crear nuevo proyecto
class CreateProject extends CreateProjectEvent {
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final Priority priority;
  final List<CreateTaskParams>? initialTasks;

  const CreateProject({
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.budget,
    required this.priority,
    this.initialTasks,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        startDate,
        endDate,
        budget,
        priority,
        initialTasks,
      ];
}

/// Actualizar proyecto existente
class UpdateProject extends CreateProjectEvent {
  final String projectId;
  final String? name;
  final String? description;
  final double? budget;
  final DateTime? endDate;
  final Priority? priority;

  const UpdateProject({
    required this.projectId,
    this.name,
    this.description,
    this.budget,
    this.endDate,
    this.priority,
  });

  @override
  List<Object?> get props => [
        projectId,
        name,
        description,
        budget,
        endDate,
        priority,
      ];
}

/// Resetear formulario
class ResetForm extends CreateProjectEvent {
  const ResetForm();
}
