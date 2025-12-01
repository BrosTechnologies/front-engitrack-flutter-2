// lib/core/networking/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../auth/auth_manager.dart';

/// Interceptor para agregar el token de autenticación a todas las requests
/// Agrega el header "Authorization: Bearer {token}" automáticamente
class AuthInterceptor extends Interceptor {
  final AuthManager _authManager;

  AuthInterceptor(this._authManager);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener el Bearer token del AuthManager
    final bearerToken = await _authManager.getBearerToken();

    // Si hay token, agregarlo al header
    if (bearerToken != null) {
      options.headers['Authorization'] = bearerToken;
    }

    // Agregar Content-Type por defecto si no está presente
    options.headers['Content-Type'] ??= 'application/json';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si el error es 401 (Unauthorized), podríamos limpiar el token
    // y redirigir al login (esto se manejará en el BLoC)
    if (err.response?.statusCode == 401) {
      // El manejo de sesión expirada se hará desde el BLoC
      // Por ahora solo pasamos el error
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
