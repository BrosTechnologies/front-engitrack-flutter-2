// lib/features/auth/presentation/widgets/auth_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget de campo de texto reutilizable para formularios de autenticación
/// Soporta validación, iconos, visibilidad de password, etc.
class AuthTextField extends StatelessWidget {
  /// Controlador del campo (opcional si se usa onChanged)
  final TextEditingController? controller;

  /// Texto de hint/placeholder
  final String hintText;

  /// Etiqueta del campo
  final String? labelText;

  /// Icono prefijo
  final IconData? prefixIcon;

  /// Si es campo de password (oculta texto)
  final bool obscureText;

  /// Widget sufijo (ej: botón de visibilidad)
  final Widget? suffixIcon;

  /// Tipo de teclado
  final TextInputType keyboardType;

  /// Acción del teclado
  final TextInputAction textInputAction;

  /// Callback cuando cambia el texto
  final ValueChanged<String>? onChanged;

  /// Callback cuando se envía
  final VoidCallback? onSubmitted;

  /// Mensaje de error
  final String? errorText;

  /// Si el campo está habilitado
  final bool enabled;

  /// Formateadores de input
  final List<TextInputFormatter>? inputFormatters;

  /// Máximo de líneas
  final int maxLines;

  /// Auto-focus
  final bool autofocus;

  /// Validador de formulario
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (si existe)
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

        // Campo de texto
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: (_) => onSubmitted?.call(),
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          autofocus: autofocus,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: errorText != null
                        ? const Color(0xFFE53E3E)
                        : Colors.grey.shade500,
                    size: 22,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF5F5F5)
                : const Color(0xFFE5E5E5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFE53E3E)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF007AFF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE53E3E),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE53E3E),
                width: 2,
              ),
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

/// Widget de campo de password con toggle de visibilidad integrado
class AuthPasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? errorText;
  final TextInputAction textInputAction;
  final bool enabled;

  const AuthPasswordField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    required this.isVisible,
    required this.onToggleVisibility,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      prefixIcon: Icons.lock_outline,
      obscureText: !isVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      errorText: errorText,
      enabled: enabled,
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade500,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }
}
