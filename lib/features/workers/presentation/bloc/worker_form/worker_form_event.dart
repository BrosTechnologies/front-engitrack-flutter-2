// lib/features/workers/presentation/bloc/worker_form/worker_form_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del bloc de formulario de worker
abstract class WorkerFormEvent extends Equatable {
  const WorkerFormEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el formulario en modo crear
/// Puede recibir datos precargados del perfil del usuario
class InitCreateWorkerEvent extends WorkerFormEvent {
  /// Nombre completo precargado (del perfil de usuario)
  final String? prefilledFullName;
  
  /// Teléfono precargado (del perfil de usuario)
  final String? prefilledPhone;

  const InitCreateWorkerEvent({
    this.prefilledFullName,
    this.prefilledPhone,
  });

  @override
  List<Object?> get props => [prefilledFullName, prefilledPhone];
}

/// Evento para inicializar el formulario en modo editar
class InitEditWorkerEvent extends WorkerFormEvent {
  final String workerId;

  const InitEditWorkerEvent(this.workerId);

  @override
  List<Object?> get props => [workerId];
}

/// Evento para actualizar el nombre completo
class UpdateFullNameEvent extends WorkerFormEvent {
  final String fullName;

  const UpdateFullNameEvent(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

/// Evento para actualizar el número de documento
class UpdateDocumentNumberEvent extends WorkerFormEvent {
  final String documentNumber;

  const UpdateDocumentNumberEvent(this.documentNumber);

  @override
  List<Object?> get props => [documentNumber];
}

/// Evento para actualizar el teléfono
class UpdatePhoneEvent extends WorkerFormEvent {
  final String phone;

  const UpdatePhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Evento para actualizar la posición/cargo
class UpdatePositionEvent extends WorkerFormEvent {
  final String position;

  const UpdatePositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Evento para actualizar la tarifa por hora
class UpdateHourlyRateEvent extends WorkerFormEvent {
  final double hourlyRate;

  const UpdateHourlyRateEvent(this.hourlyRate);

  @override
  List<Object?> get props => [hourlyRate];
}

/// Evento para guardar el worker (crear o actualizar)
class SaveWorkerEvent extends WorkerFormEvent {
  const SaveWorkerEvent();
}
