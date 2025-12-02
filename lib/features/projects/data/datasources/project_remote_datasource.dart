// lib/features/projects/data/datasources/project_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/project_dto.dart';
import '../models/task_dto.dart';
import '../models/create_project_request_dto.dart';
import '../models/create_task_request_dto.dart';
import '../models/update_project_request_dto.dart';
import '../models/update_task_status_request_dto.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Interfaz del datasource remoto de proyectos
abstract class ProjectRemoteDataSource {
  /// Obtiene lista de proyectos
  Future<List<ProjectDto>> getProjects({
    String? status,
    String? searchQuery,
    int? page,
    int? pageSize,
  });

  /// Obtiene un proyecto por ID
  Future<ProjectDto> getProjectById(String projectId);

  /// Crea un nuevo proyecto
  Future<ProjectDto> createProject(CreateProjectRequestDto request);

  /// Actualiza un proyecto
  Future<ProjectDto> updateProject(
    String projectId,
    UpdateProjectRequestDto request,
  );

  /// Elimina un proyecto
  Future<void> deleteProject(String projectId);

  /// Marca un proyecto como completado
  Future<ProjectDto> completeProject(String projectId);

  /// Crea una tarea en un proyecto
  Future<TaskDto> createTask(String projectId, CreateTaskRequestDto request);

  /// Actualiza el estado de una tarea
  Future<TaskDto> updateTaskStatus(
    String projectId,
    String taskId,
    UpdateTaskStatusRequestDto request,
  );

  /// Elimina una tarea
  Future<void> deleteTask(String projectId, String taskId);
}

/// Implementación del datasource remoto de proyectos
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProjectDto>> getProjects({
    String? status,
    String? searchQuery,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (pageSize != null) {
        queryParams['pageSize'] = pageSize;
      }

      final response = await _apiClient.get(
        ApiConstants.projects,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ProjectDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Error al obtener proyectos',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProjectDto> getProjectById(String projectId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.projectById(projectId),
      );

      if (response.statusCode == 200) {
        return ProjectDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al obtener proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProjectDto> createProject(CreateProjectRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.projects,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjectDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al crear proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProjectDto> updateProject(
    String projectId,
    UpdateProjectRequestDto request,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.projectById(projectId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ProjectDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al actualizar proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.projectById(projectId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al eliminar proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProjectDto> completeProject(String projectId) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.projectComplete(projectId),
      );

      if (response.statusCode == 200) {
        return ProjectDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al completar proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaskDto> createTask(
    String projectId,
    CreateTaskRequestDto request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.projectTasks(projectId),
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al crear tarea',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaskDto> updateTaskStatus(
    String projectId,
    String taskId,
    UpdateTaskStatusRequestDto request,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.taskStatus(projectId, taskId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return TaskDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al actualizar estado de tarea',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.taskById(projectId, taskId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al eliminar tarea',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Maneja errores de Dio y los convierte a ServerException
  ServerException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('Tiempo de conexión agotado');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Error del servidor';
        
        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? 
                   data['error'] as String? ?? 
                   message;
        }
        
        return ServerException(message, statusCode);
      case DioExceptionType.cancel:
        return ServerException('Solicitud cancelada');
      case DioExceptionType.connectionError:
        return ServerException('Error de conexión. Verifica tu internet');
      default:
        return ServerException('Error inesperado: ${e.message}');
    }
  }
}
