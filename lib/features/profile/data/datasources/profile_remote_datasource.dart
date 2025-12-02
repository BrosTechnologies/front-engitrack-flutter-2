// lib/features/profile/data/datasources/profile_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/user_profile_dto.dart';
import '../models/user_stats_dto.dart';
import '../models/update_profile_request_dto.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// DataSource remoto para operaciones de perfil
abstract class ProfileRemoteDataSource {
  /// Obtiene el perfil del usuario autenticado
  Future<UserProfileDto> getProfile();

  /// Obtiene las estadísticas del usuario
  Future<UserStatsDto> getStats();

  /// Actualiza el perfil del usuario
  Future<UserProfileDto> updateProfile(UpdateProfileRequestDto request);

  /// Obtiene un usuario por ID
  Future<UserProfileDto> getUserById(String userId);
}

/// Implementación del DataSource remoto de perfil
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserProfileDto> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        return UserProfileDto.fromJson(response.data);
      } else {
        throw ServerException(
          'Error al obtener perfil: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserStatsDto> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfileStats);

      if (response.statusCode == 200) {
        return UserStatsDto.fromJson(response.data);
      } else {
        throw ServerException(
          'Error al obtener estadísticas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserProfileDto> updateProfile(UpdateProfileRequestDto request) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.userProfile,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return UserProfileDto.fromJson(response.data);
      } else {
        throw ServerException(
          'Error al actualizar perfil: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserProfileDto> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(ApiConstants.userById(userId));

      if (response.statusCode == 200) {
        return UserProfileDto.fromJson(response.data);
      } else {
        throw ServerException(
          'Error al obtener usuario: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      String message = 'Error del servidor';

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      }

      return ServerException(
        message,
        statusCode: e.response?.statusCode,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ServerException('Tiempo de espera agotado');
    }

    if (e.type == DioExceptionType.connectionError) {
      return ServerException('Sin conexión a internet');
    }

    return ServerException('Error de conexión: ${e.message}');
  }
}
