// lib/features/auth/presentation/pages/verify_reset_code_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/password_recovery/password_recovery_bloc.dart';
import '../bloc/password_recovery/password_recovery_event.dart';
import '../bloc/password_recovery/password_recovery_state.dart';

/// Página para verificar el código de recuperación
class VerifyResetCodePage extends StatefulWidget {
  final PasswordRecoveryBloc bloc;

  const VerifyResetCodePage({
    super.key,
    required this.bloc,
  });

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
          listener: (context, state) {
            if (state is CodeVerified) {
              // Navegar a pantalla de nueva contraseña
              context.push(
                AppRouter.resetPassword,
                extra: widget.bloc,
              );
            } else if (state is PasswordRecoveryError &&
                       state.currentStep == RecoveryStep.verifyCode) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade400,
                ),
              );
              // Limpiar campos en caso de error
              for (final controller in _controllers) {
                controller.clear();
              }
              _focusNodes[0].requestFocus();
            } else if (state is ResetCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código reenviado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is VerifyingCode || state is SendingResetCode;
            final email = state.email;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Icono
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read,
                          size: 40,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Título
                    const Center(
                      child: Text(
                        'Verificar código',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Descripción
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Ingresa el código de 6 dígitos enviado a\n',
                            ),
                            TextSpan(
                              text: email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Campos de código
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF007AFF),
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              // Auto-submit cuando todos los campos están llenos
                              if (_code.length == 6) {
                                _submitCode();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón verificar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Verificar código',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reenviar código
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<PasswordRecoveryBloc>().add(
                                  const ResendCode(),
                                ),
                        child: Text(
                          '¿No recibiste el código? Reenviar',
                          style: TextStyle(
                            color: isLoading
                                ? Colors.grey.shade400
                                : const Color(0xFF007AFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitCode() {
    if (_code.length == 6) {
      context.read<PasswordRecoveryBloc>().add(VerifyCode(_code));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código completo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
