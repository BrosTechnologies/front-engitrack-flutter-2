// lib/features/profile/presentation/bloc/profile/profile_event.dart

import 'package:equatable/equatable.dart';

/// Eventos del ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el perfil y estadísticas
class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Evento para refrescar el perfil
class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}

/// Evento para eliminar el perfil de worker (usa workerId del perfil actual)
class DeleteWorkerProfileEvent extends ProfileEvent {
  const DeleteWorkerProfileEvent();
}

/// Evento para cerrar sesión
class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

/// Evento para limpiar mensajes de operación
class ClearProfileMessageEvent extends ProfileEvent {
  const ClearProfileMessageEvent();
}
