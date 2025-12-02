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

// Workers Feature imports
import '../../features/workers/data/datasources/worker_remote_datasource.dart';
import '../../features/workers/data/repositories/worker_repository_impl.dart';
import '../../features/workers/domain/repositories/worker_repository.dart';
import '../../features/workers/presentation/bloc/workers_list/workers_list_bloc.dart';
import '../../features/workers/presentation/bloc/worker_form/worker_form_bloc.dart';
import '../../features/workers/presentation/bloc/worker_assignments/worker_assignments_bloc.dart';
import '../../features/workers/presentation/bloc/project_workers/project_workers_bloc.dart';

// Profile Feature imports
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile/profile_bloc.dart';
import '../../features/profile/presentation/bloc/edit_profile/edit_profile_bloc.dart';

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

  // ============ WORKERS FEATURE ============
  // DataSource
  sl.registerLazySingleton<WorkerRemoteDataSource>(
    () => WorkerRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<WorkerRepository>(
    () => WorkerRepositoryImpl(sl<WorkerRemoteDataSource>()),
  );

  // Blocs
  sl.registerFactory<WorkersListBloc>(
    () => WorkersListBloc(sl<WorkerRepository>()),
  );

  sl.registerFactory<WorkerFormBloc>(
    () => WorkerFormBloc(sl<WorkerRepository>()),
  );

  sl.registerFactory<WorkerAssignmentsBloc>(
    () => WorkerAssignmentsBloc(sl<WorkerRepository>()),
  );

  sl.registerFactory<ProjectWorkersBloc>(
    () => ProjectWorkersBloc(sl<WorkerRepository>()),
  );

  // ============ PROFILE FEATURE ============
  // DataSource
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // Blocs
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      sl<ProfileRepository>(),
      sl<WorkerRepository>(),
      sl<AuthManager>(),
    ),
  );

  sl.registerFactory<EditProfileBloc>(
    () => EditProfileBloc(sl<ProfileRepository>()),
  );

  // ============ OTHER FEATURES ============
  // Los repositorios, casos de uso y blocs de otras features
  // se agregarán aquí en fases posteriores
}

/// Resetea todas las dependencias (útil para testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
