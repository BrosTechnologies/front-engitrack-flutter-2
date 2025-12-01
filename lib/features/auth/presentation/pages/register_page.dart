// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';

/// Página de registro de usuario
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          // Manejar error
          if (state.status == RegisterStatus.failure &&
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

          // Navegar a home si registro exitoso
          if (state.status == RegisterStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text('¡Cuenta creada exitosamente!'),
                  ],
                ),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
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
                  const SizedBox(height: 20),

                  // Botón de retroceso y título
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRouter.login),
                        icon: const Icon(Icons.arrow_back_ios),
                        color: const Color(0xFF1F2937),
                      ),
                      const Expanded(
                        child: Text(
                          'Crear Cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance para centrar título
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Completa tus datos para comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Campo de Nombre Completo
                  AuthTextField(
                    hintText: 'Juan Pérez',
                    labelText: 'Nombre Completo',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterFullNameChanged(value));
                    },
                    errorText: state.fullNameError,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Campo de Email
                  AuthTextField(
                    hintText: 'correo@ejemplo.com',
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterEmailChanged(value));
                    },
                    errorText: state.emailError,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Campo de Teléfono
                  AuthTextField(
                    hintText: '+51 999 999 999',
                    labelText: 'Teléfono',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterPhoneChanged(value));
                    },
                    errorText: state.phoneError,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Selector de Rol
                  RoleSelector(
                    labelText: 'Rol',
                    selectedRole: state.role.isNotEmpty ? state.role : null,
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<RegisterBloc>()
                            .add(RegisterRoleChanged(value));
                      }
                    },
                    errorText: state.roleError,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Campo de Password
                  AuthPasswordField(
                    hintText: 'Mínimo 6 caracteres',
                    labelText: 'Contraseña',
                    isVisible: state.isPasswordVisible,
                    onToggleVisibility: () {
                      context
                          .read<RegisterBloc>()
                          .add(const RegisterTogglePasswordVisibility());
                    },
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterPasswordChanged(value));
                    },
                    errorText: state.passwordError,
                    textInputAction: TextInputAction.next,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Campo de Confirmar Password
                  AuthPasswordField(
                    hintText: 'Repite tu contraseña',
                    labelText: 'Confirmar Contraseña',
                    isVisible: state.isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      context
                          .read<RegisterBloc>()
                          .add(const RegisterToggleConfirmPasswordVisibility());
                    },
                    onChanged: (value) {
                      context
                          .read<RegisterBloc>()
                          .add(RegisterConfirmPasswordChanged(value));
                    },
                    onSubmitted: () {
                      context
                          .read<RegisterBloc>()
                          .add(const RegisterSubmitted());
                    },
                    errorText: state.confirmPasswordError,
                    textInputAction: TextInputAction.done,
                    enabled: !state.isLoading,
                  ),

                  const SizedBox(height: 32),

                  // Botón de Registro
                  AuthButton(
                    text: 'Registrarse',
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context
                                .read<RegisterBloc>()
                                .add(const RegisterSubmitted());
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

                  // Botón de Google (placeholder)
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

                  const SizedBox(height: 24),

                  // Link a login
                  Center(
                    child: AuthTextButton(
                      text: '¿Ya tienes cuenta? ',
                      highlightedText: 'Inicia Sesión',
                      onPressed: () => context.go(AppRouter.login),
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
