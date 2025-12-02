// lib/features/projects/presentation/bloc/create_project/create_project_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

/// Estados del bloc de crear proyecto
abstract class CreateProjectState extends Equatable {
  const CreateProjectState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (formulario vacío)
class CreateProjectInitial extends CreateProjectState {
  const CreateProjectInitial();
}

/// Enviando datos al servidor
class CreateProjectSubmitting extends CreateProjectState {
  const CreateProjectSubmitting();
}

/// Proyecto creado/actualizado exitosamente
class CreateProjectSuccess extends CreateProjectState {
  final Project project;
  final bool isUpdate;

  const CreateProjectSuccess({
    required this.project,
    this.isUpdate = false,
  });

  String get message => isUpdate
      ? 'Proyecto actualizado exitosamente'
      : 'Proyecto creado exitosamente';

  @override
  List<Object?> get props => [project, isUpdate];
}

/// Error al crear/actualizar proyecto
class CreateProjectError extends CreateProjectState {
  final String message;

  const CreateProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
