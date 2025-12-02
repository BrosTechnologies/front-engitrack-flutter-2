// lib/features/profile/presentation/bloc/edit_profile/edit_profile_event.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

/// Eventos del EditProfileBloc
abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el formulario con datos actuales
class InitEditProfileEvent extends EditProfileEvent {
  /// Perfil actual (opcional, si no se pasa se carga del servidor)
  final UserProfile? profile;

  const InitEditProfileEvent([this.profile]);

  @override
  List<Object?> get props => [profile];
}

/// Evento para actualizar el nombre
class UpdateFullNameEvent extends EditProfileEvent {
  final String fullName;

  const UpdateFullNameEvent(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

/// Evento para actualizar el teléfono
class UpdatePhoneEvent extends EditProfileEvent {
  final String phone;

  const UpdatePhoneEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Evento para guardar los cambios
class SaveProfileEvent extends EditProfileEvent {
  const SaveProfileEvent();
}
