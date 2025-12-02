// lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_manager.dart';
import '../networking/api_client.dart';
import '../navigation/app_router.dart';

// Auth Feature imports
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';

// Projects Feature imports
import '../../features/projects/data/datasources/project_remote_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/presentation/bloc/projects_list/projects_list_bloc.dart';
import '../../features/projects/presentation/bloc/project_detail/project_detail_bloc.dart';
import '../../features/projects/presentation/bloc/create_project/create_project_bloc.dart';

/// Instancia global de GetIt para inyección de dependencias
final GetIt sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
/// Debe llamarse antes de runApp() en main.dart
Future<void> initializeDependencies() async {
  // ============ EXTERNAL ============
  // SharedPreferences - debe inicializarse primero (async)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ============ CORE ============
  // AuthManager - depende de SharedPreferences
  sl.registerSingleton<AuthManager>(
    AuthManager(sl<SharedPreferences>()),
  );

  // ApiClient - depende de AuthManager
  sl.registerSingleton<ApiClient>(
    ApiClient(sl<AuthManager>()),
  );

  // ============ AUTH FEATURE ============
  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthManager>(),
    ),
  );

  // Blocs (Factory - nueva instancia cada vez)
  sl.registerFactory<LoginBloc>(
    () => LoginBloc(sl<AuthRepository>()),
  );

  sl.registerFactory<RegisterBloc>(
    () => RegisterBloc(sl<AuthRepository>()),
  );

  // ============ PROJECTS FEATURE ============
  // DataSource
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(sl<ProjectRemoteDataSource>()),
  );

  // Blocs
  sl.registerFactory<ProjectsListBloc>(
    () => ProjectsListBloc(sl<ProjectRepository>()),
  );

  sl.registerFactory<ProjectDetailBloc>(
    () => ProjectDetailBloc(sl<ProjectRepository>()),
  );

  sl.registerFactory<CreateProjectBloc>(
    () => CreateProjectBloc(
      sl<ProjectRepository>(),
      sl<AuthManager>(),
    ),
  );

  // ============ NAVIGATION ============
  // AppRouter - depende de AuthManager (registrar después de auth)
  sl.registerSingleton<AppRouter>(
    AppRouter(sl<AuthManager>()),
  );

  // ============ OTHER FEATURES ============
  // Los repositorios, casos de uso y blocs de otras features
  // se agregarán aquí en fases posteriores
  
  // Workers Feature
  // sl.registerFactory(() => WorkersBloc(sl()));
}

/// Resetea todas las dependencias (útil para testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
