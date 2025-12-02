// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../auth/auth_manager.dart';

// Auth Feature Pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

// Projects Feature Pages
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/projects/presentation/pages/create_project_page.dart';
import '../../features/projects/domain/entities/project.dart';

/// Configuración de rutas de la aplicación usando GoRouter
/// Define todas las rutas y la lógica de navegación
class AppRouter {
  final AuthManager _authManager;

  AppRouter(this._authManager);

  /// Nombres de rutas para navegación type-safe
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String createProject = '/projects/create';
  static const String editProject = '/projects/edit';
  static const String profile = '/profile';
  static const String workers = '/workers';
  static const String calendar = '/calendar';
  static const String createWorkerProfile = '/create-worker-profile';

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
    final isAuthRoute = state.matchedLocation == login ||
        state.matchedLocation == register ||
        state.matchedLocation == splash;

    // Si está en splash, redirigir según estado de login
    if (state.matchedLocation == splash) {
      return isLoggedIn ? home : login;
    }

    // Si no está logueado y no está en ruta de auth, ir a login
    if (!isLoggedIn && !isAuthRoute) {
      return login;
    }

    // Si está logueado y está en ruta de auth, ir a home
    if (isLoggedIn && isAuthRoute && state.matchedLocation != splash) {
      return home;
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

        // Main app routes with bottom navigation
        ShellRoute(
          builder: (context, state, child) {
            return _MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: home,
              name: 'home',
              builder: (context, state) => const _HomePlaceholder(),
            ),
            GoRoute(
              path: projects,
              name: 'projects',
              builder: (context, state) => const ProjectsPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createProject',
                  builder: (context, state) => const CreateProjectPage(),
                ),
                GoRoute(
                  path: 'edit',
                  name: 'editProject',
                  builder: (context, state) {
                    final project = state.extra as Project?;
                    return CreateProjectPage(project: project);
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'projectDetail',
                  builder: (context, state) {
                    final projectId = state.pathParameters['id'] ?? '';
                    return ProjectDetailPage(projectId: projectId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: calendar,
              name: 'calendar',
              builder: (context, state) => const _CalendarPlaceholder(),
            ),
            GoRoute(
              path: profile,
              name: 'profile',
              builder: (context, state) => const _ProfilePlaceholder(),
            ),
          ],
        ),

        // Workers routes (outside shell)
        GoRoute(
          path: workers,
          name: 'workers',
          builder: (context, state) => const _WorkersPlaceholder(),
        ),

        // Create worker profile
        GoRoute(
          path: createWorkerProfile,
          name: 'createWorkerProfile',
          builder: (context, state) => const _CreateWorkerProfilePlaceholder(),
        ),
      ];
}

// ============ PLACEHOLDER WIDGETS ============
// Login y Register ahora usan páginas reales de features/auth/
// Los demás serán reemplazados en fases posteriores

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

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Dashboard - Placeholder'),
        ],
      ),
    );
  }
}

class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Calendario',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Calendario de eventos - Placeholder'),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatefulWidget {
  const _ProfilePlaceholder();

  @override
  State<_ProfilePlaceholder> createState() => _ProfilePlaceholderState();
}

class _ProfilePlaceholderState extends State<_ProfilePlaceholder> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    
    try {
      final authManager = GetIt.instance<AuthManager>();
      await authManager.logout();
      
      if (mounted) {
        context.go(AppRouter.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Información del usuario - Placeholder'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isLoggingOut ? null : _logout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout),
            label: Text(_isLoggingOut ? 'Cerrando sesión...' : 'Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkersPlaceholder extends StatelessWidget {
  const _WorkersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workers')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Workers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Lista de trabajadores - Placeholder'),
          ],
        ),
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

// ============ MAIN SCAFFOLD WITH BOTTOM NAVIGATION ============

class _MainScaffold extends StatelessWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRouter.home)) return 0;
    if (location.startsWith(AppRouter.projects)) return 1;
    if (location.startsWith(AppRouter.calendar)) return 2;
    if (location.startsWith(AppRouter.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.projects);
        break;
      case 2:
        context.go(AppRouter.calendar);
        break;
      case 3:
        context.go(AppRouter.profile);
        break;
    }
  }
}
