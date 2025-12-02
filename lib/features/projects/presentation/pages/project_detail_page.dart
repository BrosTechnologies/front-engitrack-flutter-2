// lib/features/projects/presentation/pages/project_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/navigation/app_router.dart';
import '../../domain/entities/task.dart';
import '../bloc/project_detail/project_detail_bloc.dart';
import '../bloc/project_detail/project_detail_event.dart';
import '../bloc/project_detail/project_detail_state.dart';
import '../widgets/project_stats_card.dart';
import '../widgets/task_list.dart';

/// Página de detalle de proyecto
class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<ProjectDetailBloc>()..add(LoadProject(projectId)),
      child: const _ProjectDetailContent(),
    );
  }
}

class _ProjectDetailContent extends StatelessWidget {
  const _ProjectDetailContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectDetailBloc, ProjectDetailState>(
      listener: (context, state) {
        // Mostrar mensaje de operación
        if (state is ProjectDetailLoaded && state.operationMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.operationMessage!),
              backgroundColor:
                  state.isOperationSuccess ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ProjectDetailBloc>().add(const ClearOperationMessage());
        }

        // Navegar si el proyecto fue eliminado
        if (state is ProjectDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proyecto eliminado'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRouter.projects);
        }
      },
      builder: (context, state) {
        if (state is ProjectDetailLoading) {
          return _buildLoading();
        } else if (state is ProjectDetailError) {
          return _buildError(context, state.message);
        } else if (state is ProjectDetailLoaded) {
          return _buildContent(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF007AFF),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar proyecto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectDetailLoaded state) {
    final project = state.project;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          project.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, value, state),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Editar'),
                  ],
                ),
              ),
              if (!project.isCompleted)
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Completar'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              context.read<ProjectDetailBloc>().add(const RefreshProject());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de estadísticas
                  ProjectStatsCard(project: project),

                  const SizedBox(height: 24),

                  // Lista de tareas agrupadas
                  GroupedTaskList(
                    tasks: project.tasks,
                    isProcessing: state.isProcessing,
                    onTaskTap: (task) => _onTaskTap(context, task),
                    onTaskDelete: (task) => _onTaskDelete(context, task),
                    onAddTask: () => _showAddTaskDialog(context, project.endDate),
                  ),

                  const SizedBox(height: 80), // Espacio para FAB
                ],
              ),
            ),
          ),

          // Loading overlay
          if (state.isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, project.endDate),
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    ProjectDetailLoaded state,
  ) async {
    switch (action) {
      case 'edit':
        final result = await context.push(
          AppRouter.editProject,
          extra: state.project,
        );
        if (result == true && context.mounted) {
          context.read<ProjectDetailBloc>().add(const RefreshProject());
        }
        break;
      case 'complete':
        _showCompleteConfirmation(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _onTaskTap(BuildContext context, Task task) {
    // Cambiar al siguiente estado
    context.read<ProjectDetailBloc>().add(
          UpdateTaskStatus(
            taskId: task.taskId,
            status: task.status.nextStatus,
          ),
        );
  }

  void _onTaskDelete(BuildContext context, Task task) {
    context.read<ProjectDetailBloc>().add(DeleteTask(task.taskId));
  }

  void _showAddTaskDialog(BuildContext context, DateTime? projectEndDate) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime? selectedDate;
    String? dateError;
    final bloc = context.read<ProjectDetailBloc>();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Si el proyecto tiene fecha y está en el futuro, usar esa fecha como máximo
    // Si el proyecto tiene fecha pero ya pasó, permitir hasta 1 año desde hoy
    // Si no tiene fecha, permitir hasta 1 año desde hoy
    final DateTime maxDate;
    final bool hasProjectEndDate = projectEndDate != null && projectEndDate.isAfter(today);
    if (hasProjectEndDate) {
      maxDate = projectEndDate;
    } else {
      maxDate = today.add(const Duration(days: 365));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Container(
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
                      const Text(
                        'Nueva Tarea',
                        style: TextStyle(
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
                      labelText: 'Título de la tarea',
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
                        context: sheetContext,
                        initialDate: initialDate.isAfter(maxDate) ? maxDate : initialDate,
                        firstDate: today,
                        lastDate: maxDate,
                        helpText: hasProjectEndDate 
                            ? 'Máximo: ${maxDate.day}/${maxDate.month}/${maxDate.year}'
                            : 'Selecciona fecha límite',
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
                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
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
                  if (hasProjectEndDate && dateError == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        'Fecha máxima: ${maxDate.day}/${maxDate.month}/${maxDate.year} (límite del proyecto)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
                        
                        // Validar fecha obligatoria
                        if (selectedDate == null) {
                          setModalState(() {
                            dateError = 'La fecha límite es obligatoria';
                          });
                          return;
                        }
                        
                        if (isFormValid) {
                          bloc.add(AddTask(
                            title: titleController.text.trim(),
                            dueDate: selectedDate,
                          ));
                          Navigator.pop(sheetContext);
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
                      child: const Text(
                        'Agregar Tarea',
                        style: TextStyle(
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

  void _showCompleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Completar proyecto'),
        content: const Text(
          '¿Estás seguro de marcar este proyecto como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProjectDetailBloc>().add(const CompleteProject());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text(
          '¿Estás seguro de eliminar este proyecto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProjectDetailBloc>().add(const DeleteProject());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
