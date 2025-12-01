// lib/core/auth/auth_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Manager de autenticación que gestiona el almacenamiento local
/// Equivalente al AuthManager de la app Kotlin original
class AuthManager {
  final SharedPreferences _prefs;

  AuthManager(this._prefs);

  // ============ KEYS ============
  static const String _keyJwtToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyWorkerId = 'worker_id';

  // ============ TOKEN METHODS ============

  /// Guarda el JWT token
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyJwtToken, token);
  }

  /// Obtiene el JWT token
  Future<String?> getToken() async {
    return _prefs.getString(_keyJwtToken);
  }

  /// Obtiene el Bearer token formateado ("Bearer {token}")
  Future<String?> getBearerToken() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return 'Bearer $token';
    }
    return null;
  }

  // ============ USER DATA METHODS ============

  /// Guarda los datos del usuario
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String role,
    required String fullName,
  }) async {
    await Future.wait([
      _prefs.setString(_keyUserId, userId),
      _prefs.setString(_keyUserEmail, email),
      _prefs.setString(_keyUserRole, role),
      _prefs.setString(_keyUserFullName, fullName),
    ]);
  }

  /// Obtiene el ID del usuario
  Future<String?> getUserId() async {
    return _prefs.getString(_keyUserId);
  }

  /// Obtiene el email del usuario
  Future<String?> getUserEmail() async {
    return _prefs.getString(_keyUserEmail);
  }

  /// Obtiene el rol del usuario
  Future<String?> getUserRole() async {
    return _prefs.getString(_keyUserRole);
  }

  /// Obtiene el nombre completo del usuario
  Future<String?> getUserFullName() async {
    return _prefs.getString(_keyUserFullName);
  }

  // ============ SESSION METHODS ============

  /// Verifica si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============ WORKER METHODS ============

  /// Guarda el ID del worker
  Future<bool> saveWorkerId(String workerId) async {
    return await _prefs.setString(_keyWorkerId, workerId);
  }

  /// Obtiene el ID del worker
  Future<String?> getWorkerId() async {
    return _prefs.getString(_keyWorkerId);
  }

  /// Limpia el ID del worker
  Future<bool> clearWorkerId() async {
    return await _prefs.remove(_keyWorkerId);
  }

  // ============ LOGOUT ============

  /// Cierra sesión - limpia todos los datos guardados
  Future<void> logout() async {
    await Future.wait([
      _prefs.remove(_keyJwtToken),
      _prefs.remove(_keyUserId),
      _prefs.remove(_keyUserEmail),
      _prefs.remove(_keyUserRole),
      _prefs.remove(_keyUserFullName),
      _prefs.remove(_keyWorkerId),
    ]);
  }
}
