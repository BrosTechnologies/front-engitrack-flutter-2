// lib/features/auth/presentation/widgets/role_selector.dart

import 'package:flutter/material.dart';

/// Widget selector de rol para el registro
/// Muestra un dropdown con los roles disponibles
class RoleSelector extends StatelessWidget {
  /// Rol seleccionado actualmente
  final String? selectedRole;

  /// Callback cuando cambia el rol
  final ValueChanged<String?> onChanged;

  /// Mensaje de error
  final String? errorText;

  /// Si está habilitado
  final bool enabled;

  /// Etiqueta del campo
  final String? labelText;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.labelText,
  });

  /// Lista de roles disponibles
  static const List<RoleOption> roles = [
    RoleOption(
      value: 'SUPERVISOR',
      displayName: 'Supervisor',
      description: 'Gestiona proyectos y asigna tareas',
      icon: Icons.manage_accounts,
    ),
    RoleOption(
      value: 'CONTRACTOR',
      displayName: 'Contratista',
      description: 'Trabaja en proyectos asignados',
      icon: Icons.engineering,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFFF5F5F5)
                : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFE53E3E)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: selectedRole?.isNotEmpty == true ? selectedRole : null,
              onChanged: enabled ? onChanged : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.work_outline,
                  color: Colors.grey,
                  size: 22,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
              hint: Text(
                'Selecciona tu rol',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade500,
              ),
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role.value,
                  child: Row(
                    children: [
                      Icon(
                        role.icon,
                        size: 20,
                        color: const Color(0xFF007AFF),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            role.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          if (role.description.isNotEmpty)
                            Text(
                              role.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Mensaje de error
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 14,
                color: Color(0xFFE53E3E),
              ),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE53E3E),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Modelo para las opciones de rol
class RoleOption {
  final String value;
  final String displayName;
  final String description;
  final IconData icon;

  const RoleOption({
    required this.value,
    required this.displayName,
    required this.description,
    required this.icon,
  });
}
