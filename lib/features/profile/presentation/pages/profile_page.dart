// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/worker_section_card.dart';

/// Página principal de perfil de usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const LoadProfileEvent()),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Logout exitoso
          if (state is ProfileLoggedOut) {
            context.go('/login');
          }

          // Error de logout
          if (state is ProfileError && state.isLogoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          // Mensaje de éxito
          if (state is ProfileLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProfileError && !state.isLogoutError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ProfileLoaded) {
            return _buildLoadedState(context, state);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(const LoadProfileEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, ProfileLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(const RefreshProfileEvent());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header con información del usuario
          SliverToBoxAdapter(
            child: ProfileHeader(profile: state.profile),
          ),

          // Espaciador
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Card de estadísticas
          SliverToBoxAdapter(
            child: ProfileStatsCard(
              stats: state.stats,
              isLoading: state.isLoadingStats,
            ),
          ),

          // Sección de trabajador
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: WorkerSectionCard(
                profile: state.profile,
                isDeletingWorker: state.isDeletingWorker,
                onViewWorkerProfile: state.profile.hasWorkerProfile
                    ? () => _navigateToWorkerDetail(context, state.profile.workerId!)
                    : null,
                onCreateWorkerProfile: () => _navigateToCreateWorker(context),
                onDeleteWorkerProfile: () => _showDeleteWorkerDialog(context),
              ),
            ),
          ),

          // Sección de cuenta
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'CUENTA',
              children: [
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Editar perfil',
                  subtitle: 'Nombre y teléfono',
                  onTap: () => _navigateToEditProfile(context),
                ),
                ProfileMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Cambiar contraseña',
                  subtitle: 'Actualiza tu contraseña',
                  onTap: () => _showComingSoonSnackbar(context),
                ),
              ],
            ),
          ),

          // Sección de aplicación
          SliverToBoxAdapter(
            child: ProfileMenuSection(
              title: 'APLICACIÓN',
              children: [
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  subtitle: 'Versión 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),

          // Botón de cerrar sesión
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: state.isLoggingOut
                    ? null
                    : () => _showLogoutDialog(context),
                icon: state.isLoggingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(state.isLoggingOut
                    ? 'Cerrando sesión...'
                    : 'Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Espaciador inferior
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    context.push('/edit-profile');
  }

  void _navigateToWorkerDetail(BuildContext context, String workerId) {
    context.push('/workers/$workerId');
  }

  void _navigateToCreateWorker(BuildContext context) {
    context.push('/workers/create');
  }

  void _showDeleteWorkerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Desvincular perfil de trabajador'),
        content: const Text(
          '¿Estás seguro de que deseas desvincular tu perfil de trabajador? '
          'Esta acción eliminará tu perfil de trabajador y no podrás ser '
          'asignado a proyectos ni tareas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(const DeleteWorkerProfileEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(const LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.engineering, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('EngiTrack'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Sistema de gestión de proyectos y trabajadores '
              'para empresas de ingeniería.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 EngiTrack',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente disponible'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
