// lib/features/profile/presentation/bloc/profile/profile_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/user_stats.dart';

/// Estados del ProfileBloc
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Cargando perfil
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Perfil cargado exitosamente
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final UserStats stats;
  final bool isLoadingStats;
  final bool isDeletingWorker;
  final bool isLoggingOut;
  final String? successMessage;
  final bool isProcessing;

  const ProfileLoaded({
    required this.profile,
    required this.stats,
    this.isLoadingStats = false,
    this.isDeletingWorker = false,
    this.isLoggingOut = false,
    this.successMessage,
    this.isProcessing = false,
  });

  /// Constructor conveniente desde datos
  factory ProfileLoaded.success({
    required UserProfile profile,
    required UserStats stats,
  }) {
    return ProfileLoaded(
      profile: profile,
      stats: stats,
    );
  }

  ProfileLoaded copyWith({
    UserProfile? profile,
    UserStats? stats,
    bool? isLoadingStats,
    bool? isDeletingWorker,
    bool? isLoggingOut,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? isProcessing,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isDeletingWorker: isDeletingWorker ?? this.isDeletingWorker,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        stats,
        isLoadingStats,
        isDeletingWorker,
        isLoggingOut,
        successMessage,
        isProcessing,
      ];
}

/// Error al cargar perfil
class ProfileError extends ProfileState {
  final String message;
  final bool isLogoutError;

  const ProfileError(this.message, {this.isLogoutError = false});

  @override
  List<Object?> get props => [message, isLogoutError];
}

/// Sesión cerrada exitosamente
class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
