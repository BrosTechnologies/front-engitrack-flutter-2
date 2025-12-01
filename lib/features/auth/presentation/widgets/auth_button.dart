// lib/features/auth/presentation/widgets/auth_button.dart

import 'package:flutter/material.dart';

/// Botón primario para formularios de autenticación
/// Soporta estado de loading y disabled
class AuthButton extends StatelessWidget {
  /// Texto del botón
  final String text;

  /// Callback cuando se presiona
  final VoidCallback? onPressed;

  /// Si está en estado de carga
  final bool isLoading;

  /// Color de fondo del botón
  final Color? backgroundColor;

  /// Color del texto
  final Color? textColor;

  /// Ancho del botón (por defecto ocupa todo el ancho)
  final double? width;

  /// Alto del botón
  final double height;

  /// Icono opcional
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF007AFF);
    final fgColor = textColor ?? Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          disabledForegroundColor: fgColor.withValues(alpha: 0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón secundario (outline) para acciones alternativas
class AuthOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final Widget? iconWidget;

  const AuthOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bColor = borderColor ?? const Color(0xFF007AFF);
    final tColor = textColor ?? const Color(0xFF007AFF);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tColor,
          side: BorderSide(color: bColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(tColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconWidget != null) ...[
                    iconWidget!,
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón de texto para links
class AuthTextButton extends StatelessWidget {
  final String text;
  final String? highlightedText;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Color? highlightColor;

  const AuthTextButton({
    super.key,
    required this.text,
    this.highlightedText,
    this.onPressed,
    this.textColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final tColor = textColor ?? Colors.grey.shade600;
    final hColor = highlightColor ?? const Color(0xFF007AFF);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      child: highlightedText != null
          ? RichText(
              text: TextSpan(
                text: text,
                style: TextStyle(
                  fontSize: 14,
                  color: tColor,
                ),
                children: [
                  TextSpan(
                    text: highlightedText,
                    style: TextStyle(
                      fontSize: 14,
                      color: hColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: hColor,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
