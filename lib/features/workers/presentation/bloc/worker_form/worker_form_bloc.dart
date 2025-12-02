// lib/features/workers/presentation/bloc/worker_form/worker_form_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/worker_repository.dart';
import 'worker_form_event.dart';
import 'worker_form_state.dart';

/// Bloc para manejar el formulario de worker
class WorkerFormBloc extends Bloc<WorkerFormEvent, WorkerFormState> {
  final WorkerRepository _workerRepository;

  WorkerFormBloc(this._workerRepository) : super(WorkerFormState.initial()) {
    on<InitCreateWorkerEvent>(_onInitCreate);
    on<InitEditWorkerEvent>(_onInitEdit);
    on<UpdateFullNameEvent>(_onUpdateFullName);
    on<UpdateDocumentNumberEvent>(_onUpdateDocumentNumber);
    on<UpdatePhoneEvent>(_onUpdatePhone);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<UpdateHourlyRateEvent>(_onUpdateHourlyRate);
    on<SaveWorkerEvent>(_onSaveWorker);
  }

  void _onInitCreate(
    InitCreateWorkerEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(WorkerFormState.initial());
  }

  Future<void> _onInitEdit(
    InitEditWorkerEvent event,
    Emitter<WorkerFormState> emit,
  ) async {
    emit(WorkerFormState.editing(event.workerId));

    final result = await _workerRepository.getWorkerById(event.workerId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (worker) => emit(state.copyWith(
        isLoading: false,
        fullName: worker.fullName,
        documentNumber: worker.documentNumber,
        phone: worker.phone,
        position: worker.position,
        hourlyRate: worker.hourlyRate,
      )),
    );
  }

  void _onUpdateFullName(
    UpdateFullNameEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onUpdateDocumentNumber(
    UpdateDocumentNumberEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(state.copyWith(documentNumber: event.documentNumber));
  }

  void _onUpdatePhone(
    UpdatePhoneEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateHourlyRate(
    UpdateHourlyRateEvent event,
    Emitter<WorkerFormState> emit,
  ) {
    emit(state.copyWith(hourlyRate: event.hourlyRate));
  }

  Future<void> _onSaveWorker(
    SaveWorkerEvent event,
    Emitter<WorkerFormState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        errorMessage: 'Por favor completa todos los campos correctamente',
      ));
      return;
    }

    emit(state.copyWith(isSaving: true));

    if (state.isEditing && state.workerId != null) {
      // Actualizar worker existente
      final result = await _workerRepository.updateWorker(
        state.workerId!,
        UpdateWorkerParams(
          fullName: state.fullName,
          documentNumber: state.documentNumber,
          phone: state.phone,
          position: state.position,
          hourlyRate: state.hourlyRate,
        ),
      );

      result.fold(
        (failure) => emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        )),
        (worker) => emit(state.copyWith(
          isSaving: false,
          isSaved: true,
          savedWorker: worker,
        )),
      );
    } else {
      // Crear nuevo worker
      final result = await _workerRepository.createWorker(
        CreateWorkerParams(
          fullName: state.fullName,
          documentNumber: state.documentNumber,
          phone: state.phone,
          position: state.position,
          hourlyRate: state.hourlyRate,
        ),
      );

      result.fold(
        (failure) => emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        )),
        (worker) => emit(state.copyWith(
          isSaving: false,
          isSaved: true,
          savedWorker: worker,
        )),
      );
    }
  }
}
