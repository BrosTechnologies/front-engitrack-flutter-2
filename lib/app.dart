// lib/app.dart

import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget principal de la aplicación EngiTrack
/// Configura MaterialApp.router con GoRouter, tema y DI
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el router desde el contenedor de inyección
    final appRouter = sl<AppRouter>();

    return MaterialApp.router(
      // Configuración básica
      title: 'EngiTrack',
      debugShowCheckedModeBanner: false,

      // Tema de la aplicación
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Por defecto usar tema claro

      // Configuración del router (GoRouter)
      routerConfig: appRouter.router,

      // Builder para configuraciones globales (opcional)
      builder: (context, child) {
        // Aquí se pueden agregar widgets globales como:
        // - Overlay para loading global
        // - Configuración de MediaQuery
        // - Wrappers de providers adicionales
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
