// lib/core/networking/api_constants.dart

/// Constantes de la API para EngiTrack
/// Contiene todas las URLs y endpoints del backend
class ApiConstants {
  // Prevenir instanciación
  ApiConstants._();

  /// URL base del backend en Railway
  static const String baseUrl =
      'https://engitrack-backend-production.up.railway.app';

  // ============ AUTH ENDPOINTS ============
  /// POST - Login de usuario
  static const String login = '/auth/login';

  /// POST - Registro de usuario
  static const String register = '/auth/register';

  /// POST - Solicitar código de recuperación de contraseña
  static const String forgotPassword = '/auth/forgot-password';

  /// POST - Verificar código de recuperación
  static const String verifyResetCode = '/auth/verify-reset-code';

  /// POST - Restablecer contraseña con código
  static const String resetPassword = '/auth/reset-password';

  // ============ PROJECTS ENDPOINTS ============
  /// GET - Listar proyectos / POST - Crear proyecto
  static const String projects = '/api/projects';

  /// GET/PUT/DELETE - Proyecto por ID
  static String projectById(String id) => '/api/projects/$id';

  /// GET - Proyectos por usuario
  static String projectsByUser(String userId) => '/api/projects/user/$userId';

  /// PATCH - Completar proyecto
  static String projectComplete(String id) => '/api/projects/$id/complete';

  // ============ TASKS ENDPOINTS ============
  /// GET - Tareas de un proyecto / POST - Crear tarea
  static String projectTasks(String projectId) =>
      '/api/projects/$projectId/tasks';

  /// Alias para compatibilidad
  static String tasksByProject(String projectId) => projectTasks(projectId);

  /// DELETE - Tarea por ID
  static String taskById(String projectId, String taskId) =>
      '/api/projects/$projectId/tasks/$taskId';

  /// PATCH - Actualizar estado de tarea
  static String taskStatus(String projectId, String taskId) =>
      '/api/projects/$projectId/tasks/$taskId/status';

  // ============ WORKERS ENDPOINTS ============
  /// GET - Listar workers / POST - Crear worker
  static const String workers = '/api/workers';

  /// GET/PUT/DELETE - Worker por ID
  static String workerById(String id) => '/api/workers/$id';

  /// GET - Worker por userId
  static String workerByUserId(String userId) => '/api/workers/user/$userId';

  // ============ PROJECT WORKERS ENDPOINTS ============
  /// POST - Asignar worker a proyecto
  static String assignWorkerToProject(String projectId) =>
      '/api/projects/$projectId/workers';

  /// DELETE - Remover worker de proyecto
  static String removeWorkerFromProject(String projectId, String workerId) =>
      '/api/projects/$projectId/workers/$workerId';

  // ============ USER PROFILE ENDPOINTS ============
  /// GET/PATCH - Perfil del usuario actual
  static const String userProfile = '/api/users/profile';

  /// GET - Estadísticas del usuario actual
  static const String userProfileStats = '/api/users/profile/stats';

  /// GET - Usuario por ID
  static String userById(String id) => '/api/users/$id';

  /// POST - Cambiar contraseña del usuario autenticado
  static const String changePassword = '/api/users/change-password';

  // ============ TIMEOUTS ============
  /// Timeout para conexión en milisegundos
  static const int connectionTimeout = 30000;

  /// Timeout para recibir datos en milisegundos
  static const int receiveTimeout = 30000;

  /// Timeout para enviar datos en milisegundos
  static const int sendTimeout = 30000;
}
