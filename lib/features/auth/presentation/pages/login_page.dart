// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Página de inicio de sesión
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          // Manejar error
          if (state.status == LoginStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: const Color(0xFFE53E3E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          // Navegar a home si login exitoso
          if (state.status == LoginStatus.success) {
            context.go(AppRouter.home);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo/Icono
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.engineering,
                        size: 50,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'EngiTrack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Campo de Email
                  AuthTextField(
                    hintText: 'correo@ejemplo.com',
                    labelText: 'Correo electrónico',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      context.read<LoginBloc>().add(LoginEmailChanged(value));
                    },
                    errorText: state.emailError,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 20),

                  // Campo de Password
                  AuthPasswordField(
                    hintText: 'Tu contraseña',
                    labelText: 'Contraseña',
                    isVisible: state.isPasswordVisible,
                    onToggleVisibility: () {
                      context
                          .read<LoginBloc>()
                          .add(const LoginTogglePasswordVisibility());
                    },
                    onChanged: (value) {
                      context
                          .read<LoginBloc>()
                          .add(LoginPasswordChanged(value));
                    },
                    onSubmitted: () {
                      context.read<LoginBloc>().add(const LoginSubmitted());
                    },
                    errorText: state.passwordError,
                    textInputAction: TextInputAction.done,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Link "¿Olvidaste tu contraseña?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context.push(AppRouter.forgotPassword),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón de Login
                  AuthButton(
                    text: 'Iniciar Sesión',
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context
                                .read<LoginBloc>()
                                .add(const LoginSubmitted());
                          },
                    isLoading: state.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Divider con texto
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botón de Google (placeholder - funcionalidad futura)
                  AuthOutlineButton(
                    text: 'Continuar con Google',
                    borderColor: const Color(0xFF4CAF50),
                    textColor: const Color(0xFF4CAF50),
                    iconWidget: Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.g_mobiledata,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google Sign-In próximamente'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Link a registro
                  Center(
                    child: AuthTextButton(
                      text: '¿No tienes cuenta? ',
                      highlightedText: 'Regístrate',
                      onPressed: () => context.go(AppRouter.register),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
