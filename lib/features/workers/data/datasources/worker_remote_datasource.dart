// lib/features/workers/data/datasources/worker_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/worker_dto.dart';
import '../models/project_worker_dto.dart';
import '../models/worker_assignment_dto.dart';
import '../models/create_worker_request_dto.dart';
import '../models/update_worker_request_dto.dart';
import '../models/assign_worker_request_dto.dart';

/// Excepción personalizada para errores del servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Interfaz del datasource remoto de workers
abstract class WorkerRemoteDataSource {
  /// Obtiene lista de todos los workers
  Future<List<WorkerDto>> getWorkers();

  /// Obtiene un worker por ID
  Future<WorkerDto> getWorkerById(String workerId);

  /// Crea un nuevo worker
  Future<WorkerDto> createWorker(CreateWorkerRequestDto request);

  /// Actualiza un worker
  Future<WorkerDto> updateWorker(
    String workerId,
    UpdateWorkerRequestDto request,
  );

  /// Elimina un worker
  Future<void> deleteWorker(String workerId);

  /// Obtiene las asignaciones de un worker
  Future<List<WorkerAssignmentDto>> getWorkerAssignments(String workerId);

  /// Obtiene los workers asignados a un proyecto
  Future<List<ProjectWorkerDto>> getProjectWorkers(String projectId);

  /// Asigna un worker a un proyecto
  Future<ProjectWorkerDto> assignWorkerToProject(
    String projectId,
    AssignWorkerRequestDto request,
  );

  /// Remueve un worker de un proyecto
  Future<void> removeWorkerFromProject(String projectId, String workerId);
}

/// Implementación del datasource remoto de workers
class WorkerRemoteDataSourceImpl implements WorkerRemoteDataSource {
  final ApiClient _apiClient;

  WorkerRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<WorkerDto>> getWorkers() async {
    try {
      final response = await _apiClient.get(ApiConstants.workers);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => WorkerDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Error al obtener workers',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<WorkerDto> getWorkerById(String workerId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workerById(workerId),
      );

      if (response.statusCode == 200) {
        return WorkerDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al obtener worker',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<WorkerDto> createWorker(CreateWorkerRequestDto request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.workers,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WorkerDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al crear worker',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<WorkerDto> updateWorker(
    String workerId,
    UpdateWorkerRequestDto request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.workerById(workerId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return WorkerDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al actualizar worker',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteWorker(String workerId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.workerById(workerId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al eliminar worker',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<WorkerAssignmentDto>> getWorkerAssignments(
    String workerId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.workerById(workerId)}/assignments',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                WorkerAssignmentDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Error al obtener asignaciones',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProjectWorkerDto>> getProjectWorkers(String projectId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.assignWorkerToProject(projectId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                ProjectWorkerDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Error al obtener workers del proyecto',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProjectWorkerDto> assignWorkerToProject(
    String projectId,
    AssignWorkerRequestDto request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.assignWorkerToProject(projectId),
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjectWorkerDto.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          'Error al asignar worker',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeWorkerFromProject(
    String projectId,
    String workerId,
  ) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.removeWorkerFromProject(projectId, workerId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Error al remover worker del proyecto',
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
