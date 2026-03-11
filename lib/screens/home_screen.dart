import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../contants/colors.dart';
import '../models/todo_list_model.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<List<TodoModel>>(context);
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );

    final pendingTodos = todos.where((todo) => !todo.isDone).toList();
    final completedTodos = todos.where((todo) => todo.isDone).toList();

    pendingTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Todos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_add,
                    size: 80,
                    color: AppColors.primary.withOpacity(.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No todos yet.\nTap + to add one!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                if (pendingTodos.isNotEmpty) ...[
                  _buildSectionHeader('Pending Tasks (${pendingTodos.length})'),
                  ...pendingTodos.map(
                    (todo) => _buildTodoItem(context, todo, databaseService),
                  ),
                ],
                if (completedTodos.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Completed Tasks (${completedTodos.length})',
                  ),
                  ...completedTodos.map(
                    (todo) => _buildTodoItem(context, todo, databaseService),
                  ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTodoDialog(context, databaseService);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showTodoDialog(
    BuildContext context,
    DatabaseService databaseService, {
    TodoModel? todo,
  }) {
    final bool isEditing = todo != null;
    final TextEditingController titleController = TextEditingController(
      text: todo?.title ?? '',
    );
    DateTime? selectedDate = todo?.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              // FIX: Wrapped in SingleChildScrollView to prevent pixel overflow
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: isEditing
                            ? 'Enter todo title'
                            : 'What needs to be done?',
                        prefixIcon: Icon(
                          isEditing
                              ? Icons.edit_outlined
                              : Icons.check_circle_outline,
                          color: AppColors.textSecondary,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedDate == null
                                ? Colors.transparent
                                : AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: selectedDate == null
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? (isEditing
                                        ? 'No Date Chosen'
                                        : 'Set Due Date')
                                  : DateFormat(
                                      'MMM d, yyyy',
                                    ).format(selectedDate!),
                              style: TextStyle(
                                color: selectedDate == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      if (isEditing) {
                        databaseService.updateTodo(
                          todo.id,
                          titleController.text.trim(),
                          selectedDate,
                        );
                      } else {
                        databaseService.addTodo(
                          titleController.text.trim(),
                          selectedDate,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? "Save Changes" : "Add Task"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTodoItem(
    BuildContext context,
    TodoModel todo,
    DatabaseService databaseService,
  ) {
    final bool isOverdue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isDone;

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showTodoDialog(context, databaseService, todo: todo);
          return false;
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          databaseService.deleteTodo(todo.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Checkbox(
            value: todo.isDone,
            activeColor: AppColors.success,
            onChanged: (bool? value) {
              if (value != null) {
                databaseService.updateTodoStatus(todo.id, value);
              }
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone
                  ? AppColors.textSecondary.withOpacity(0.6)
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: todo.dueDate != null
              ? Text(
                  DateFormat('MMM d, yyyy').format(todo.dueDate!),
                  style: TextStyle(
                    color: isOverdue
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
