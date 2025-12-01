// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

/// Clase base abstracta para representar fallos en la aplicación
/// Usado con `Either<Failure, Success>` de dartz
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Fallo de servidor (errores HTTP, timeout, etc)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Fallo de validación (datos inválidos)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fallo de autenticación (401, credenciales inválidas)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Fallo de conexión (sin internet)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Fallo de caché (datos locales no disponibles)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
