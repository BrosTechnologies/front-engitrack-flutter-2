// lib/core/networking/api_client.dart

import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../auth/auth_manager.dart';

/// Cliente HTTP configurado para la API de EngiTrack
/// Utiliza Dio con interceptores para autenticación y logging
class ApiClient {
  late final Dio _dio;

  ApiClient(AuthManager authManager) {
    _dio = Dio(_baseOptions);
    _configureInterceptors(authManager);
  }

  /// Configuración base de Dio
  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(
          milliseconds: ApiConstants.sendTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

  /// Configura los interceptores
  void _configureInterceptors(AuthManager authManager) {
    // Interceptor de autenticación (agrega Bearer token)
    _dio.interceptors.add(AuthInterceptor(authManager));

    // Log interceptor para debug (solo en desarrollo)
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // En producción, esto se puede reemplazar por un logger apropiado
          // ignore: avoid_print
          print('🌐 API: $obj');
        },
      ),
    );
  }

  /// Instancia de Dio para uso directo
  Dio get dio => _dio;

  // ============ MÉTODOS HTTP ============

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
