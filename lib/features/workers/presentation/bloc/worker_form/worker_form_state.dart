// lib/features/workers/presentation/bloc/worker_form/worker_form_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/worker.dart';

/// Estados del bloc de formulario de worker
class WorkerFormState extends Equatable {
  final bool isEditing;
  final String? workerId;
  final String fullName;
  final String documentNumber;
  final String phone;
  final String position;
  final double hourlyRate;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSaved;
  final Worker? savedWorker;

  const WorkerFormState({
    this.isEditing = false,
    this.workerId,
    this.fullName = '',
    this.documentNumber = '',
    this.phone = '',
    this.position = '',
    this.hourlyRate = 0.0,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSaved = false,
    this.savedWorker,
  });

  /// Estado inicial para crear
  factory WorkerFormState.initial() => const WorkerFormState();

  /// Estado inicial para editar
  factory WorkerFormState.editing(String workerId) => WorkerFormState(
        isEditing: true,
        workerId: workerId,
        isLoading: true,
      );

  /// Verifica si el formulario es válido
  bool get isValid =>
      fullName.isNotEmpty &&
      documentNumber.isNotEmpty &&
      phone.isNotEmpty &&
      position.isNotEmpty &&
      hourlyRate > 0;

  /// Copia el estado con nuevos valores
  WorkerFormState copyWith({
    bool? isEditing,
    String? workerId,
    String? fullName,
    String? documentNumber,
    String? phone,
    String? position,
    double? hourlyRate,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSaved,
    Worker? savedWorker,
  }) {
    return WorkerFormState(
      isEditing: isEditing ?? this.isEditing,
      workerId: workerId ?? this.workerId,
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
      savedWorker: savedWorker ?? this.savedWorker,
    );
  }

  @override
  List<Object?> get props => [
        isEditing,
        workerId,
        fullName,
        documentNumber,
        phone,
        position,
        hourlyRate,
        isLoading,
        isSaving,
        errorMessage,
        isSaved,
        savedWorker,
      ];
}
