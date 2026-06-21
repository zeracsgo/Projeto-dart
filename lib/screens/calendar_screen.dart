import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import 'task_list_screen.dart';
import 'login_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String userName;

  const CalendarScreen({super.key, required this.userName});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final Map<DateTime, List<Task>> _tasks = {};

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks[_normalize(day)] ?? [];
  }

  void _onTasksUpdated(DateTime day, List<Task> updatedTasks) {
    setState(() {
      _tasks[_normalize(day)] = updatedTasks;
    });
  }

  int _pendingCount(DateTime day) =>
      _getTasksForDay(day).where((t) => !t.completed).length;

  int _completedCount(DateTime day) =>
      _getTasksForDay(day).where((t) => t.completed).length;

  @override
  Widget build(BuildContext context) {
    final todayTasks = _getTasksForDay(_selectedDay);
    final pending = todayTasks.where((t) => !t.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Olá, ${widget.userName.split(' ').first}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Seu calendário',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.secondary),
            tooltip: 'Sair',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 8),
          _buildDaySummary(pending, todayTasks.length),
          const SizedBox(height: 8),
          _buildOpenTasksButton(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TableCalendar<Task>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getTasksForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
          weekendTextStyle:
              const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w600),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
              color: AppTheme.accent, fontWeight: FontWeight.bold),
          selectedTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          markerDecoration: const BoxDecoration(
            color: AppTheme.secondary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: AppTheme.primary),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: AppTheme.primary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          weekendStyle: TextStyle(color: AppTheme.secondary, fontSize: 12),
        ),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) {
          _focusedDay = focused;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (ctx, date, tasks) {
            if (tasks.isEmpty) return null;
            final pending = tasks.where((t) => !t.completed).length;
            final done = tasks.where((t) => t.completed).length;
            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pending > 0)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (done > 0)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDaySummary(int pending, int total) {
    final completed = total - pending;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Pendentes',
              pending.toString(),
              AppTheme.secondary,
              Icons.radio_button_unchecked,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              'Concluídas',
              completed.toString(),
              AppTheme.success,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              'Total',
              total.toString(),
              AppTheme.accent,
              Icons.list_alt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenTasksButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final updatedTasks = await Navigator.push<List<Task>>(
              context,
              MaterialPageRoute(
                builder: (_) => TaskListScreen(
                  selectedDay: _selectedDay,
                  tasks: List.from(_getTasksForDay(_selectedDay)),
                ),
              ),
            );
            if (updatedTasks != null) {
              _onTasksUpdated(_selectedDay, updatedTasks);
            }
          },
          icon: const Icon(Icons.checklist_rtl),
          label: const Text('Ver Tarefas do Dia'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Deseja realmente sair?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
