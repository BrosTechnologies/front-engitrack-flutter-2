// lib/features/profile/presentation/widgets/worker_section_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';

/// Widget card para la sección de trabajador en el perfil
class WorkerSectionCard extends StatelessWidget {
  /// Perfil del usuario
  final UserProfile profile;

  /// Callback para ver perfil de trabajador
  final VoidCallback? onViewWorkerProfile;

  /// Callback para crear perfil de trabajador
  final VoidCallback? onCreateWorkerProfile;

  /// Callback para eliminar perfil de trabajador
  final VoidCallback? onDeleteWorkerProfile;

  /// Si está cargando la eliminación
  final bool isDeletingWorker;

  const WorkerSectionCard({
    super.key,
    required this.profile,
    this.onViewWorkerProfile,
    this.onCreateWorkerProfile,
    this.onDeleteWorkerProfile,
    this.isDeletingWorker = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: profile.hasWorkerProfile
            ? _buildHasWorkerProfile(context)
            : _buildNoWorkerProfile(context),
      ),
    );
  }

  Widget _buildHasWorkerProfile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.engineering,
                color: AppColors.secondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfil de Trabajador',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Vinculado',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Acciones
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onViewWorkerProfile,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Ver perfil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isDeletingWorker ? null : onDeleteWorkerProfile,
                icon: isDeletingWorker
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Icon(Icons.link_off, size: 18),
                label: Text(isDeletingWorker ? 'Desvinculando...' : 'Desvincular'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: isDeletingWorker
                        ? AppColors.error.withValues(alpha: 0.5)
                        : AppColors.error,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoWorkerProfile(BuildContext context) {
    return Column(
      children: [
        // Icono y mensaje
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person_add_outlined,
            color: Colors.grey.shade400,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sin perfil de trabajador',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Crea tu perfil de trabajador para ser asignado a proyectos y tareas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        // Botón crear
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCreateWorkerProfile,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Crear perfil de trabajador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
