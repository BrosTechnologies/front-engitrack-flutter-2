// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

/// Punto de entrada de la aplicación EngiTrack
/// Inicializa las dependencias antes de ejecutar la app
void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de localización para DateFormat
  await initializeDateFormatting('es_ES', null);

  // Configurar orientación preferida (solo portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inicializar inyección de dependencias
  await initializeDependencies();

  // Ejecutar la aplicación
  runApp(const MyApp());
}

