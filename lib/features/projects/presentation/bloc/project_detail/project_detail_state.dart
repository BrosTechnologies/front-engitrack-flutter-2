// lib/features/projects/presentation/bloc/project_detail/project_detail_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

/// Estados del bloc de detalle de proyecto
abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProjectDetailInitial extends ProjectDetailState {
  const ProjectDetailInitial();
}

/// Cargando proyecto
class ProjectDetailLoading extends ProjectDetailState {
  const ProjectDetailLoading();
}

/// Proyecto cargado exitosamente
class ProjectDetailLoaded extends ProjectDetailState {
  final Project project;
  final String? operationMessage;
  final bool isOperationSuccess;
  final bool isProcessing;

  const ProjectDetailLoaded({
    required this.project,
    this.operationMessage,
    this.isOperationSuccess = false,
    this.isProcessing = false,
  });

  ProjectDetailLoaded copyWith({
    Project? project,
    String? operationMessage,
    bool? isOperationSuccess,
    bool? isProcessing,
    bool clearMessage = false,
  }) {
    return ProjectDetailLoaded(
      project: project ?? this.project,
      operationMessage: clearMessage ? null : (operationMessage ?? this.operationMessage),
      isOperationSuccess: isOperationSuccess ?? this.isOperationSuccess,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
        project,
        operationMessage,
        isOperationSuccess,
        isProcessing,
      ];
}

/// Error al cargar o procesar proyecto
class ProjectDetailError extends ProjectDetailState {
  final String message;

  const ProjectDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Proyecto eliminado exitosamente
class ProjectDeleted extends ProjectDetailState {
  const ProjectDeleted();
}
