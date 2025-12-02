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
  String? _dateError;

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

                      // Fecha límite (obligatoria)
                      _buildDateFieldRequired(
                        label: 'Fecha Límite *',
                        value: _endDate,
                        onChanged: (date) => setState(() {
                          _endDate = date;
                          // Actualizar tareas que tengan fecha mayor a la nueva fecha límite
                          for (var task in _tasks) {
                            if (task.dueDate != null && date != null && task.dueDate!.isAfter(date)) {
                              task.dueDate = date;
                            }
                          }
                        }),
                        errorText: _dateError,
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

  Widget _buildDateFieldRequired({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    String? errorText,
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
              initialDate: value ?? DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              helpText: 'Selecciona fecha límite',
              cancelText: 'Cancelar',
              confirmText: 'Seleccionar',
            );
            if (date != null) {
              setState(() => _dateError = null);
              onChanged(date);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: errorText != null 
                  ? Border.all(color: Colors.red, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: errorText != null ? Colors.red : Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('dd/MM/yyyy').format(value)
                        : 'Seleccionar fecha límite',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
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
        const SizedBox(height: 12),
        if (_tasks.isEmpty)
          InkWell(
            onTap: _showAddTaskSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_task,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar primera tarea',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para agregar tareas al proyecto',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt,
              color: Color(0xFF007AFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title.isEmpty ? 'Tarea ${index + 1}' : task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: task.dueDate != null 
                          ? const Color(0xFF007AFF)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate != null
                          ? DateFormat('dd MMM yyyy', 'es_ES').format(task.dueDate!)
                          : 'Sin fecha límite',
                      style: TextStyle(
                        fontSize: 13,
                        color: task.dueDate != null 
                            ? const Color(0xFF007AFF)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 20),
            onPressed: () => _showEditTaskSheet(index),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
            onPressed: () => _removeTask(index),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet() {
    if (_endDate == null) {
      setState(() => _dateError = 'Primero selecciona la fecha límite del proyecto');
      return;
    }
    _showTaskSheet(null);
  }

  void _showEditTaskSheet(int index) {
    _showTaskSheet(index);
  }

  void _showTaskSheet(int? editIndex) {
    final isEditing = editIndex != null;
    final task = isEditing ? _tasks[editIndex] : null;
    
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: task?.title ?? '');
    DateTime? selectedDate = task?.dueDate;
    String? dateError;
    
    final today = DateTime.now();
    final maxDate = _endDate!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Editar Tarea' : 'Nueva Tarea',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Título
                  TextFormField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Título de la tarea *',
                      hintText: 'Ingresa el título...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha límite (obligatoria)
                  InkWell(
                    onTap: () async {
                      final initialDate = selectedDate ?? 
                          (today.isBefore(maxDate) ? today.add(const Duration(days: 1)) : today);
                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate.isAfter(maxDate) ? maxDate : initialDate,
                        firstDate: today,
                        lastDate: maxDate,
                        helpText: 'Fecha límite de la tarea',
                        cancelText: 'Cancelar',
                        confirmText: 'Seleccionar',
                      );
                      if (date != null) {
                        setModalState(() {
                          selectedDate = date;
                          dateError = null;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dateError != null ? Colors.red : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: dateError != null ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                  : 'Seleccionar fecha límite *',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedDate != null
                                    ? Colors.black
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  if (dateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        dateError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'La fecha debe ser anterior o igual a: ${DateFormat('dd/MM/yyyy').format(maxDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final isFormValid = formKey.currentState!.validate();
                        
                        if (selectedDate == null) {
                          setModalState(() {
                            dateError = 'La fecha límite es obligatoria';
                          });
                          return;
                        }
                        
                        if (isFormValid) {
                          setState(() {
                            if (isEditing) {
                              _tasks[editIndex].title = titleController.text.trim();
                              _tasks[editIndex].dueDate = selectedDate;
                            } else {
                              _tasks.add(_TaskInput(
                                title: titleController.text.trim(),
                                dueDate: selectedDate,
                              ));
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Guardar Cambios' : 'Agregar Tarea',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addTask() {
    _showAddTaskSheet();
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

    // Validar fecha límite obligatoria
    if (_endDate == null) {
      setState(() => _dateError = 'La fecha límite es obligatoria');
      return;
    }

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
      // Filtrar tareas vacías y con fecha válida
      final validTasks = _tasks
          .where((t) => t.title.trim().isNotEmpty && t.dueDate != null)
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

  _TaskInput({
    this.title = '',
    this.dueDate,
  });
}
