// lib/features/profile/presentation/bloc/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/auth_manager.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../../workers/domain/repositories/worker_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Bloc para manejar el estado del perfil
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final WorkerRepository _workerRepository;
  final AuthManager _authManager;

  ProfileBloc(
    this._profileRepository,
    this._workerRepository,
    this._authManager,
  ) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<DeleteWorkerProfileEvent>(_onDeleteWorkerProfile);
    on<LogoutEvent>(_onLogout);
    on<ClearProfileMessageEvent>(_onClearMessage);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    // Cargar perfil y estadísticas en paralelo
    final profileResult = await _profileRepository.getProfile();
    final statsResult = await _profileRepository.getStats();

    await profileResult.fold(
      (failure) async => emit(ProfileError(failure.message)),
      (profile) async {
        await statsResult.fold(
          (failure) async => emit(ProfileError(failure.message)),
          (stats) async {
            // Verificar si tiene workerId guardado
            final workerId = await _authManager.getWorkerId();
            final profileWithWorker = workerId != null
                ? profile.copyWith(workerId: workerId)
                : profile;

            emit(ProfileLoaded.success(
              profile: profileWithWorker,
              stats: stats,
            ));
          },
        );
      },
    );
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Mantener el estado actual mientras recarga
    final currentState = state;

    final profileResult = await _profileRepository.getProfile();
    final statsResult = await _profileRepository.getStats();

    await profileResult.fold(
      (failure) async {
        if (currentState is ProfileLoaded) {
          emit(ProfileError(failure.message));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (profile) async {
        await statsResult.fold(
          (failure) async {
            if (currentState is ProfileLoaded) {
              emit(ProfileError(failure.message));
            }
          },
          (stats) async {
            final workerId = await _authManager.getWorkerId();
            final profileWithWorker = workerId != null
                ? profile.copyWith(workerId: workerId)
                : profile;

            emit(ProfileLoaded.success(
              profile: profileWithWorker,
              stats: stats,
            ));
          },
        );
      },
    );
  }

  Future<void> _onDeleteWorkerProfile(
    DeleteWorkerProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    final workerId = currentState.profile.workerId;
    if (workerId == null) return;

    emit(currentState.copyWith(isDeletingWorker: true));

    final result = await _workerRepository.deleteWorker(workerId.toString());

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(
          isDeletingWorker: false,
        ));
        emit(ProfileError(failure.message));
      },
      (_) async {
        // Limpiar workerId del storage
        await _authManager.clearWorkerId();

        // Actualizar perfil sin workerId
        final updatedProfile = currentState.profile.copyWith(workerId: null);
        emit(ProfileLoaded(
          profile: updatedProfile,
          stats: currentState.stats,
          successMessage: 'Perfil de trabajador desvinculado',
        ));
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isLoggingOut: true));
    }

    try {
      await _authManager.logout();
      emit(const ProfileLoggedOut());
    } catch (e) {
      if (currentState is ProfileLoaded) {
        emit(currentState.copyWith(isLoggingOut: false));
      }
      emit(ProfileError('Error al cerrar sesión: $e', isLogoutError: true));
    }
  }

  void _onClearMessage(
    ClearProfileMessageEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(clearSuccessMessage: true));
    }
  }
}
