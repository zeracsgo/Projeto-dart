import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskListScreen extends StatefulWidget {
  final DateTime selectedDay;
  final List<Task> tasks;

  const TaskListScreen({
    super.key,
    required this.selectedDay,
    required this.tasks,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  List<Task> get _pending => _tasks
      .where((t) => !t.completed)
      .toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  List<Task> get _completed => _tasks
      .where((t) => t.completed)
      .toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  void _addTask(String title) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      date: widget.selectedDay,
    );
    setState(() => _tasks.add(task));
  }

  void _removeTask(Task task) {
    setState(() => _tasks.remove(task));
  }

  void _toggleTask(Task task) {
    setState(() => task.completed = !task.completed);
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Nova Tarefa',
          style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Descrição da tarefa...',
            prefixIcon: Icon(Icons.edit_note),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              _addTask(v);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                _addTask(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover tarefa',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Remover "${task.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _removeTask(task);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(widget.selectedDay);
    final pending = _pending;
    final completed = _completed;
    final total = _tasks.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pop(context, _tasks);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Lista de Tarefas',
                  style: TextStyle(fontSize: 18)),
              Text(
                dateStr,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context, _tasks),
          ),
        ),
        body: Column(
          children: [
            _buildProgressBar(completed.length, total),
            Expanded(
              child: _tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      children: [
                        if (pending.isNotEmpty) ...[
                          _buildSectionHeader(
                              'Pendentes', AppTheme.secondary),
                          ...pending.map((t) => _buildTaskTile(t)),
                        ],
                        if (completed.isNotEmpty) ...[
                          _buildSectionHeader(
                              'Concluídas', AppTheme.success),
                          ...completed.map((t) => _buildTaskTile(t)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Nova Tarefa'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: task.completed
              ? AppTheme.success.withOpacity(0.08)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.completed
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.primary.withOpacity(0.2),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: () => _toggleTask(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    task.completed ? AppTheme.success : Colors.transparent,
                border: Border.all(
                  color: task.completed
                      ? AppTheme.success
                      : AppTheme.textSecondary,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.completed
                  ? AppTheme.textSecondary
                  : AppTheme.textPrimary,
              decoration:
                  task.completed ? TextDecoration.lineThrough : null,
              fontWeight:
                  task.completed ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppTheme.secondary.withOpacity(0.7),
              size: 20,
            ),
            onPressed: () => _confirmDelete(task),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int completedCount, int total) {
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount de $total tarefas concluídas',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color:
                      progress == 1 ? AppTheme.success : AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.cardColor,
              valueColor: AlwaysStoppedAnimation(
                  progress == 1 ? AppTheme.success : AppTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 72,
            color: AppTheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma tarefa para este dia',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no botão + para adicionar',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
