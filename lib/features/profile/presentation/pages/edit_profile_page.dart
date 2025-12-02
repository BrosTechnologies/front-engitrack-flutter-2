// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/edit_profile/edit_profile_bloc.dart';
import '../bloc/edit_profile/edit_profile_event.dart';
import '../bloc/edit_profile/edit_profile_state.dart';

/// Página para editar el perfil del usuario
class EditProfilePage extends StatelessWidget {
  /// Perfil actual del usuario (opcional, se puede pasar como extra)
  final UserProfile? profile;

  const EditProfilePage({
    super.key,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditProfileBloc>()..add(InitEditProfileEvent(profile)),
      child: const _EditProfilePageContent(),
    );
  }
}

class _EditProfilePageContent extends StatefulWidget {
  const _EditProfilePageContent();

  @override
  State<_EditProfilePageContent> createState() => _EditProfilePageContentState();
}

class _EditProfilePageContentState extends State<_EditProfilePageContent> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        // Actualizar controllers cuando se carga el perfil
        if (state.fullName.isNotEmpty &&
            _fullNameController.text != state.fullName) {
          _fullNameController.text = state.fullName;
        }
        if (state.phone != null &&
            state.phone!.isNotEmpty &&
            _phoneController.text != state.phone) {
          _phoneController.text = state.phone!;
        }

        // Éxito al guardar
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(true); // Devolver true para indicar que se actualizó
        }

        // Error al guardar
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Editar Perfil'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: state.isLoading && state.fullName.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(context, state),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, EditProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(state.fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Email (solo lectura)
            if (state.email != null) ...[
              _buildReadOnlyField(
                label: 'Correo electrónico',
                value: state.email!,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
            ],

            // Rol (solo lectura)
            if (state.role != null) ...[
              _buildReadOnlyField(
                label: 'Rol',
                value: _formatRole(state.role!),
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 24),
            ],

            // Campos editables
            Card(
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información editable',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre completo
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: state.fullNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        context.read<EditProfileBloc>().add(
                              UpdateFullNameEvent(value),
                            );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono (opcional)',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: state.phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: '+51 999 999 999',
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        context.read<EditProfileBloc>().add(
                              UpdatePhoneEvent(value),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            ElevatedButton(
              onPressed: state.isValid && !state.isSaving
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        context.read<EditProfileBloc>().add(
                              const SaveProfileEvent(),
                            );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Botón cancelar
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: Colors.grey.shade400,
            size: 18,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'user':
        return 'Usuario';
      case 'manager':
        return 'Gestor';
      default:
        return role;
    }
  }
}
