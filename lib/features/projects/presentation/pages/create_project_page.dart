// lib/features/projects/presentation/pages/create_project_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project.dart';
import '../../domain/enums/priority.dart';
import '../../domain/repositories/project_repository.dart';
import '../bloc/create_project/create_project_bloc.dart';
import '../bloc/create_project/create_project_event.dart';
import '../bloc/create_project/create_project_state.dart';

/// Página para crear o editar un proyecto
class CreateProjectPage extends StatelessWidget {
  /// Proyecto a editar (null si es nuevo)
  final Project? project;

  const CreateProjectPage({
    super.key,
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CreateProjectBloc>(),
      child: _CreateProjectContent(project: project),
    );
  }
}

class _CreateProjectContent extends StatefulWidget {
  final Project? project;

  const _CreateProjectContent({this.project});

  @override
  State<_CreateProjectContent> createState() => _CreateProjectContentState();
}

class _CreateProjectContentState extends State<_CreateProjectContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _endDate;
  Priority _priority = Priority.medium;
  final List<_TaskInput> _tasks = [];

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final project = widget.project!;
    _nameController.text = project.name;
    _descriptionController.text = project.description ?? '';
    if (project.budget != null) {
      _budgetController.text = project.budget!.toStringAsFixed(0);
    }
    _endDate = project.endDate;
    _priority = project.priority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProjectBloc, CreateProjectState>(
      listener: (context, state) {
        if (state is CreateProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Retornar true para indicar éxito
        } else if (state is CreateProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del proyecto
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre del Proyecto',
                        hint: 'Ingresa el nombre...',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          if (value.trim().length < 3) {
                            return 'Mínimo 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        hint: 'Describe el proyecto...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Fecha límite
                      _buildDateField(
                        label: 'Fecha Límite',
                        value: _endDate,
                        onChanged: (date) => setState(() => _endDate = date),
                      ),
                      const SizedBox(height: 16),

                      // Prioridad
                      _buildPrioritySelector(),
                      const SizedBox(height: 16),

                      // Presupuesto
                      _buildTextField(
                        controller: _budgetController,
                        label: 'Presupuesto (opcional)',
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        prefixText: 'S/ ',
                      ),

                      // Solo mostrar sección de tareas si es nuevo proyecto
                      if (!isEditing) ...[
                        const SizedBox(height: 24),
                        _buildTasksSection(),
                      ],
                    ],
                  ),
                ),
              ),

              // Botón guardar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
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

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            onChanged(date);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('dd/MM/yyyy').format(value)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridad',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<Priority>(
            // ignore: deprecated_member_use
            value: _priority,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: Priority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: priority.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      priority.displayName,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tareas iniciales',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            TextButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Sin tareas. Agrega tareas para organizar tu proyecto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildTaskItem(index);
            },
          ),
      ],
    );
  }

  Widget _buildTaskItem(int index) {
    final task = _tasks[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: task.title,
                  decoration: const InputDecoration(
                    hintText: 'Título de la tarea',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => task.title = value,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: task.dueDate ??
                          DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => task.dueDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.dueDate != null
                            ? DateFormat('dd/MM/yyyy').format(task.dueDate!)
                            : 'Sin fecha',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
            onPressed: () => _removeTask(index),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    setState(() {
      _tasks.add(_TaskInput());
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  Widget _buildSaveButton() {
    return BlocBuilder<CreateProjectBloc, CreateProjectState>(
      builder: (context, state) {
        final isLoading = state is CreateProjectSubmitting;

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
                onPressed: isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Guardar Cambios' : 'Guardar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final budget = _budgetController.text.isNotEmpty
        ? double.tryParse(_budgetController.text)
        : null;

    if (isEditing) {
      context.read<CreateProjectBloc>().add(UpdateProject(
            projectId: widget.project!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            budget: budget,
            endDate: _endDate,
            priority: _priority,
          ));
    } else {
      // Filtrar tareas vacías
      final validTasks = _tasks
          .where((t) => t.title.trim().isNotEmpty)
          .map((t) => CreateTaskParams(
                title: t.title.trim(),
                dueDate: t.dueDate,
              ))
          .toList();

      context.read<CreateProjectBloc>().add(CreateProject(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            startDate: DateTime.now(),
            endDate: _endDate,
            budget: budget,
            priority: _priority,
            initialTasks: validTasks.isNotEmpty ? validTasks : null,
          ));
    }
  }
}

/// Clase auxiliar para manejar input de tareas
class _TaskInput {
  String title;
  DateTime? dueDate;

  // ignore: unused_element
  _TaskInput({
    // ignore: unused_element_parameter
    this.title = '',
    // ignore: unused_element_parameter
    this.dueDate,
  });
}
