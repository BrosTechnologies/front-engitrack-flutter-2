// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/auth_response_dto.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/forgot_password_request_dto.dart';
import '../models/verify_reset_code_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/change_password_request_dto.dart';

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message (statusCode: $statusCode)';
}

/// DataSource remoto para operaciones de autenticación
/// Maneja las llamadas HTTP a los endpoints de auth
abstract class AuthRemoteDataSource {
  /// Realiza login y retorna el DTO de respuesta
  /// Throws [AuthException] si hay error
  Future<AuthResponseDto> login(LoginRequestDto request);

  /// Realiza registro y retorna el DTO de respuesta
  /// Throws [AuthException] si hay error
  Future<AuthResponseDto> register(RegisterRequestDto request);
  
  /// Solicita código de recuperación de contraseña
  /// Throws [AuthException] si hay error
  Future<void> forgotPassword(ForgotPasswordRequestDto request);
  
  /// Verifica el código de recuperación
  /// Throws [AuthException] si hay error
  Future<void> verifyResetCode(VerifyResetCodeRequestDto request);
  
  /// Restablece la contraseña con el código verificado
  /// Throws [AuthException] si hay error
  Future<void> resetPassword(ResetPasswordRequestDto request);
  
  /// Cambia la contraseña del usuario autenticado
  /// Throws [AuthException] si hay error
  Future<void> changePassword(ChangePasswordRequestDto request);
}

/// Implementación del DataSource remoto de autenticación
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
      }

      throw const AuthException('Respuesta inválida del servidor');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          return AuthResponseDto.fromJson(
              response.data as Map<String, dynamic>);
        }
      }

      throw const AuthException('Respuesta inválida del servidor');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const AuthException('Error al enviar código de recuperación');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> verifyResetCode(VerifyResetCodeRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyResetCode,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validar el campo "valid" de la respuesta
        final data = response.data as Map<String, dynamic>?;
        final isValid = data?['valid'] as bool? ?? false;
        
        if (!isValid) {
          throw const AuthException('Código inválido o expirado');
        }
      } else {
        throw const AuthException('Error al verificar código');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const AuthException('Error al restablecer contraseña');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.changePassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const AuthException('Error al cambiar contraseña');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Maneja los errores de Dio y los convierte en AuthException
  AuthException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AuthException(
          'Tiempo de espera agotado. Verifica tu conexión.',
        );

      case DioExceptionType.connectionError:
        return const AuthException(
          'Error de conexión. Verifica tu internet.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const AuthException('Petición cancelada');

      default:
        return AuthException(
          error.message ?? 'Error desconocido',
        );
    }
  }

  /// Maneja respuestas de error HTTP
  AuthException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Intentar extraer mensaje de error del body
    String? errorMessage;
    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        return AuthException(
          errorMessage ?? 'Datos inválidos. Verifica la información.',
          statusCode: 400,
        );

      case 401:
        return AuthException(
          errorMessage ?? 'Credenciales incorrectas',
          statusCode: 401,
        );

      case 403:
        return AuthException(
          errorMessage ?? 'Acceso denegado',
          statusCode: 403,
        );

      case 404:
        return AuthException(
          errorMessage ?? 'Servicio no encontrado',
          statusCode: 404,
        );

      case 409:
        return AuthException(
          errorMessage ?? 'El email ya está registrado',
          statusCode: 409,
        );

      case 422:
        return AuthException(
          errorMessage ?? 'Error de validación',
          statusCode: 422,
        );

      case 500:
      case 502:
      case 503:
        return AuthException(
          'Error en el servidor. Intenta más tarde.',
          statusCode: statusCode,
        );

      default:
        return AuthException(
          errorMessage ?? 'Error inesperado',
          statusCode: statusCode,
        );
    }
  }
}
