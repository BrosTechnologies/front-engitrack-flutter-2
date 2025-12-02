// lib/features/profile/presentation/bloc/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/auth_manager.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../../workers/domain/repositories/worker_repository.dart';
import '../../../domain/entities/user_profile.dart';
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

  /// Busca el workerId del usuario, primero en AuthManager, luego en la lista de workers
  Future<String?> _findWorkerId(UserProfile profile) async {
    // 1. Primero verificar si ya tenemos el workerId guardado
    final savedWorkerId = await _authManager.getWorkerId();
    if (savedWorkerId != null && savedWorkerId.isNotEmpty) {
      return savedWorkerId;
    }

    // 2. Si no está guardado, buscar en la lista de workers por fullName
    try {
      final workersResult = await _workerRepository.getWorkers();
      
      return workersResult.fold(
        (failure) => null,
        (workers) {
          // Buscar un worker que coincida con el fullName del perfil
          final matchingWorker = workers.where(
            (worker) => worker.fullName.toLowerCase() == profile.fullName.toLowerCase()
          ).firstOrNull;
          
          if (matchingWorker != null) {
            // Guardar el workerId encontrado para futuras consultas
            _authManager.saveWorkerId(matchingWorker.id);
            return matchingWorker.id;
          }
          return null;
        },
      );
    } catch (e) {
      return null;
    }
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
            // Buscar el workerId (guardado o en la lista de workers)
            final workerId = await _findWorkerId(profile);
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
            // Buscar el workerId (guardado o en la lista de workers)
            final workerId = await _findWorkerId(profile);
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

        // Actualizar perfil sin workerId (usar clearWorkerId para establecer a null)
        final updatedProfile = currentState.profile.copyWith(clearWorkerId: true);
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
