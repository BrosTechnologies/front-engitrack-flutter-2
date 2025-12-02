// lib/features/projects/presentation/bloc/project_detail/project_detail_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/enums/task_status.dart';

/// Eventos del bloc de detalle de proyecto
abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar proyecto por ID
class LoadProject extends ProjectDetailEvent {
  final String projectId;

  const LoadProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Refrescar proyecto
class RefreshProject extends ProjectDetailEvent {
  const RefreshProject();
}

/// Agregar tarea al proyecto
class AddTask extends ProjectDetailEvent {
  final String title;
  final DateTime? dueDate;

  const AddTask({
    required this.title,
    this.dueDate,
  });

  @override
  List<Object?> get props => [title, dueDate];
}

/// Actualizar estado de una tarea
class UpdateTaskStatus extends ProjectDetailEvent {
  final String taskId;
  final TaskStatus status;

  const UpdateTaskStatus({
    required this.taskId,
    required this.status,
  });

  @override
  List<Object?> get props => [taskId, status];
}

/// Eliminar tarea
class DeleteTask extends ProjectDetailEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Completar proyecto
class CompleteProject extends ProjectDetailEvent {
  const CompleteProject();
}

/// Eliminar proyecto
class DeleteProject extends ProjectDetailEvent {
  const DeleteProject();
}

/// Limpiar mensaje de operación
class ClearOperationMessage extends ProjectDetailEvent {
  const ClearOperationMessage();
}
