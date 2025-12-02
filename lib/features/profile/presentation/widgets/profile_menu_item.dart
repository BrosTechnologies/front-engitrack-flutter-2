// lib/features/profile/presentation/widgets/profile_menu_item.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget para item de menú en el perfil
class ProfileMenuItem extends StatelessWidget {
  /// Icono del item
  final IconData icon;

  /// Color del icono
  final Color? iconColor;

  /// Título del item
  final String title;

  /// Subtítulo opcional
  final String? subtitle;

  /// Widget trailing personalizado
  final Widget? trailing;

  /// Si mostrar flecha
  final bool showArrow;

  /// Callback al presionar
  final VoidCallback? onTap;

  /// Si es peligroso (logout, eliminar)
  final bool isDanger;

  /// Si está cargando
  final bool isLoading;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.showArrow = true,
    this.onTap,
    this.isDanger = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDanger
        ? AppColors.error
        : iconColor ?? AppColors.primary;

    final effectiveTextColor = isDanger
        ? AppColors.error
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icono con background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: effectiveTextColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (trailing != null)
                trailing!
              else if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para sección de menú con título
class ProfileMenuSection extends StatelessWidget {
  /// Título de la sección
  final String? title;

  /// Items del menú
  final List<Widget> children;

  const ProfileMenuSection({
    super.key,
    this.title,
    required this.children,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
