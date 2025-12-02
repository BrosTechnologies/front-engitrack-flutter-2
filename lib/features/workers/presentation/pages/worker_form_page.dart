// lib/features/workers/presentation/pages/worker_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/worker_repository.dart';
import '../bloc/worker_form/worker_form_bloc.dart';
import '../bloc/worker_form/worker_form_event.dart';
import '../bloc/worker_form/worker_form_state.dart';

/// Página para crear o editar un worker
class WorkerFormPage extends StatelessWidget {
  /// ID del worker a editar (null si es nuevo)
  final String? workerId;

  const WorkerFormPage({
    super.key,
    this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = WorkerFormBloc(GetIt.instance<WorkerRepository>());
        if (workerId != null) {
          bloc.add(InitEditWorkerEvent(workerId!));
        } else {
          bloc.add(const InitCreateWorkerEvent());
        }
        return bloc;
      },
      child: _WorkerFormContent(workerId: workerId),
    );
  }
}

class _WorkerFormContent extends StatefulWidget {
  final String? workerId;

  const _WorkerFormContent({this.workerId});

  @override
  State<_WorkerFormContent> createState() => _WorkerFormContentState();
}

class _WorkerFormContentState extends State<_WorkerFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  bool get isEditing => widget.workerId != null;
  bool _isInitialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _initializeControllers(WorkerFormState state) {
    if (_isInitialized) return;
    
    _fullNameController.text = state.fullName;
    _documentNumberController.text = state.documentNumber;
    _phoneController.text = state.phone;
    _positionController.text = state.position;
    if (state.hourlyRate > 0) {
      _hourlyRateController.text = state.hourlyRate.toStringAsFixed(2);
    }
    
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkerFormBloc, WorkerFormState>(
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Trabajador actualizado correctamente'
                    : 'Trabajador creado correctamente',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(state.savedWorker);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Inicializar controladores cuando se cargan los datos
        if (state.isEditing && !state.isLoading && !_isInitialized) {
          _initializeControllers(state);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(isEditing ? 'Editar Trabajador' : 'Nuevo Trabajador'),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre completo
                              _buildTextField(
                                controller: _fullNameController,
                                label: 'Nombre Completo *',
                                hint: 'Ingresa el nombre completo...',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Mínimo 3 caracteres';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context
                                      .read<WorkerFormBloc>()
                                      .add(UpdateFullNameEvent(value));
                                },
                              ),
                              const SizedBox(height: 16),

                              // Número de documento
                              _buildTextField(
                                controller: _documentNumberController,
                                label: 'Número de Documento *',
                                hint: 'DNI o documento...',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(12),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El documento es requerido';
                                  }
                                  if (value.length < 8) {
                                    return 'Documento inválido';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context
                                      .read<WorkerFormBloc>()
                                      .add(UpdateDocumentNumberEvent(value));
                                },
                              ),
                              const SizedBox(height: 16),

                              // Teléfono
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Teléfono *',
                                hint: '999 999 999',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d\s+-]'),
                                  ),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El teléfono es requerido';
                                  }
                                  if (value.replaceAll(RegExp(r'\D'), '').length < 9) {
                                    return 'Teléfono inválido';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context
                                      .read<WorkerFormBloc>()
                                      .add(UpdatePhoneEvent(value));
                                },
                              ),
                              const SizedBox(height: 16),

                              // Cargo/Posición
                              _buildTextField(
                                controller: _positionController,
                                label: 'Cargo/Posición *',
                                hint: 'Ej: Ingeniero, Técnico, etc.',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El cargo es requerido';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context
                                      .read<WorkerFormBloc>()
                                      .add(UpdatePositionEvent(value));
                                },
                              ),
                              const SizedBox(height: 16),

                              // Tarifa por hora
                              _buildTextField(
                                controller: _hourlyRateController,
                                label: 'Tarifa por Hora (S/) *',
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                prefixText: 'S/ ',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'La tarifa es requerida';
                                  }
                                  final rate = double.tryParse(value);
                                  if (rate == null || rate <= 0) {
                                    return 'Ingresa una tarifa válida';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final rate = double.tryParse(value) ?? 0;
                                  context
                                      .read<WorkerFormBloc>()
                                      .add(UpdateHourlyRateEvent(rate));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón guardar
                      _buildSaveButton(state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: prefixText,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(WorkerFormState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isSaving ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEditing ? 'Guardar Cambios' : 'Crear Trabajador',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    context.read<WorkerFormBloc>().add(const SaveWorkerEvent());
  }
}
