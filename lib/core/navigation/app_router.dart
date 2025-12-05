// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_manager.dart';

// Auth Feature Pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_reset_code_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/bloc/password_recovery/password_recovery_bloc.dart';

// Main Feature Page (with Bottom Navigation)
import '../../features/main/presentation/pages/main_page.dart';

// Projects Feature Pages
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/projects/presentation/pages/create_project_page.dart';
import '../../features/projects/domain/entities/project.dart';

// Workers Feature Pages
import '../../features/workers/presentation/pages/workers_selector_page.dart';
import '../../features/workers/presentation/pages/worker_form_page.dart';
import '../../features/workers/presentation/pages/worker_detail_page.dart';
import '../../features/workers/presentation/pages/worker_assignments_page.dart';

// Profile Feature Pages
import '../../features/profile/presentation/pages/edit_profile_page.dart';

/// Configuración de rutas de la aplicación usando GoRouter
/// Define todas las rutas y la lógica de navegación
class AppRouter {
  final AuthManager _authManager;

  AppRouter(this._authManager);

  /// Nombres de rutas para navegación type-safe
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyResetCode = '/verify-reset-code';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String createProject = '/projects/create';
  static const String editProject = '/projects/edit';
  static const String profile = '/profile';
  static const String workers = '/workers';
  static const String workerForm = '/worker-form';
  static const String workerEdit = '/worker-form/:id';
  static const String workerAssignments = '/worker-assignments';
  static const String calendar = '/calendar';
  static const String createWorkerProfile = '/create-worker-profile';
  static const String projectAddWorker = '/projects/:id/add-worker';
  static const String editProfile = '/edit-profile';
  static const String workerDetail = '/workers/:id';

  /// Configuración del router
  late final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: _routes,
  );

  /// Maneja redirecciones basadas en estado de autenticación
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = await _authManager.isLoggedIn();
    final location = state.matchedLocation;
    
    // Rutas públicas de auth (no requieren autenticación)
    final isPublicAuthRoute = location == login ||
        location == register ||
        location == splash ||
        location == forgotPassword ||
        location == verifyResetCode ||
        location == resetPassword;

    // Si está en splash, redirigir según estado de login
    if (location == splash) {
      return isLoggedIn ? main : login;
    }

    // Si no está logueado y no está en ruta pública, ir a login
    if (!isLoggedIn && !isPublicAuthRoute) {
      return login;
    }

    // Si está logueado y está en login/register, ir a main
    if (isLoggedIn && (location == login || location == register)) {
      return main;
    }

    return null;
  }

  /// Lista de rutas de la aplicación
  List<RouteBase> get _routes => [
        // Splash / Initial redirect
        GoRoute(
          path: splash,
          builder: (context, state) => const _SplashPlaceholder(),
        ),

        // Auth routes - PÁGINAS REALES
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        
        // Password Recovery Routes
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: verifyResetCode,
          name: 'verifyResetCode',
          builder: (context, state) {
            final bloc = state.extra as PasswordRecoveryBloc;
            return VerifyResetCodePage(bloc: bloc);
          },
        ),
        GoRoute(
          path: resetPassword,
          name: 'resetPassword',
          builder: (context, state) {
            final bloc = state.extra as PasswordRecoveryBloc;
            return ResetPasswordPage(bloc: bloc);
          },
        ),
        GoRoute(
          path: changePassword,
          name: 'changePassword',
          builder: (context, state) => const ChangePasswordPage(),
        ),

        // Main page with bottom navigation (Dashboard, Projects, Calendar, Profile)
        GoRoute(
          path: main,
          name: 'main',
          builder: (context, state) => const MainPage(),
        ),

        // Legacy home redirect to main
        GoRoute(
          path: home,
          redirect: (context, state) => main,
        ),

        // Projects routes (standalone - for deep navigation)
        GoRoute(
          path: projects,
          name: 'projects',
          builder: (context, state) => const ProjectsPage(),
        ),
        GoRoute(
          path: '/projects/create',
          name: 'createProject',
          builder: (context, state) => const CreateProjectPage(),
        ),
        GoRoute(
          path: '/projects/edit',
          name: 'editProject',
          builder: (context, state) {
            final project = state.extra as Project?;
            return CreateProjectPage(project: project);
          },
        ),
        GoRoute(
          path: '/projects/:id',
          name: 'projectDetail',
          builder: (context, state) {
            final projectId = state.pathParameters['id'] ?? '';
            return ProjectDetailPage(projectId: projectId);
          },
        ),

        // Workers routes (outside shell)
        GoRoute(
          path: workers,
          name: 'workers',
          builder: (context, state) => const WorkersSelectorPage(),
        ),

        // Worker form - create
        GoRoute(
          path: workerForm,
          name: 'workerForm',
          builder: (context, state) => const WorkerFormPage(),
        ),

        // Worker form - edit
        GoRoute(
          path: '/worker-form/:id',
          name: 'workerEdit',
          builder: (context, state) {
            final workerId = state.pathParameters['id'];
            return WorkerFormPage(workerId: workerId);
          },
        ),

        // Worker assignments
        GoRoute(
          path: workerAssignments,
          name: 'workerAssignments',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            final workerId = extra?['workerId'] ?? '';
            final workerName = extra?['workerName'];
            return WorkerAssignmentsPage(
              workerId: workerId,
              workerName: workerName,
            );
          },
        ),

        // Add worker to project
        GoRoute(
          path: '/projects/:id/add-worker',
          name: 'projectAddWorker',
          builder: (context, state) {
            final projectId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;
            return WorkersSelectorPage(
              projectId: projectId,
              projectName: extra?['projectName'] as String?,
              projectEndDate: extra?['projectEndDate'] as DateTime?,
            );
          },
        ),

        // Create worker profile
        GoRoute(
          path: createWorkerProfile,
          name: 'createWorkerProfile',
          builder: (context, state) => const _CreateWorkerProfilePlaceholder(),
        ),

        // Edit profile
        GoRoute(
          path: editProfile,
          name: 'editProfile',
          builder: (context, state) => const EditProfilePage(),
        ),

        // Workers create (for profile) - MUST be before /workers/:id
        GoRoute(
          path: '/workers/create',
          name: 'workersCreate',
          builder: (context, state) {
            final extra = state.extra as Map<String, String?>?;
            return WorkerFormPage(
              prefilledFullName: extra?['fullName'],
              prefilledPhone: extra?['phone'],
            );
          },
        ),

        // Worker detail (view worker profile - read only)
        GoRoute(
          path: '/workers/:id',
          name: 'workerDetail',
          builder: (context, state) {
            final workerId = state.pathParameters['id'] ?? '';
            return WorkerDetailPage(workerId: workerId);
          },
        ),
      ];
}

// ============ PLACEHOLDER WIDGETS ============

class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _CreateWorkerProfilePlaceholder extends StatelessWidget {
  const _CreateWorkerProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Perfil de Worker')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Crear Perfil de Worker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Formulario de creación - Placeholder'),
          ],
        ),
      ),
    );
  }
}
