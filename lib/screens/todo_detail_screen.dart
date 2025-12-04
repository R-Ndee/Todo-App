import 'package:flutter/material.dart';
import 'package:todo_app/database/databse_helper.dart';
import '../models/todo_model.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../utils/date_formatter.dart';
import '../widgets/priority_badge.dart';
import '../widgets/category_chip.dart';
import 'add_edit_todo_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoModel todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TodoModel _todo;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _toggleComplete() async {
    final updated = _todo.copyWith(
      isCompleted: !_todo.isCompleted,
      status: !_todo.isCompleted ? 'completed' : 'pending',
    );
    await _dbHelper.update(updated);
    setState(() => _todo = updated);
  }

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Tugas', style: AppTextStyles.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus tugas ini?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Hapus', style: AppTextStyles.button),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.delete(_todo.id!);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dihapus', style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _editTodo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: _todo),
      ),
    );

    if (result == true) {
      final updated = await _dbHelper.readTodo(_todo.id!);
      if (updated != null && mounted) {
        setState(() => _todo = updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateFormatter.isOverdue(_todo.deadline) && !_todo.isCompleted;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(isOverdue),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Detail Tugas',
              style: AppTextStyles.h3,
            ),
          ),
          IconButton(
            onPressed: _editTodo,
            icon: const Icon(Icons.edit_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _deleteTodo,
            icon: const Icon(Icons.delete_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isOverdue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _todo.isCompleted
            ? AppColors.successGradient
            : isOverdue
                ? LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  )
                : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_todo.isCompleted
                    ? AppColors.success
                    : isOverdue
                        ? AppColors.error
                        : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _todo.isCompleted
                    ? Icons.check_circle_rounded
                    : isOverdue
                        ? Icons.error_rounded
                        : Icons.radio_button_unchecked_rounded,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _todo.isCompleted
                      ? 'Selesai'
                      : isOverdue
                          ? 'Terlambat'
                          : 'Belum Selesai',
                  style: AppTextStyles.h3.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _todo.title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.white,
              decoration: _todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          if (_todo.description != null && _todo.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _todo.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.9),
                decoration: _todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Tugas', style: AppTextStyles.h4),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'Kategori',
            child: CategoryChip(category: _todo.category),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.flag_rounded,
            label: 'Prioritas',
            child: PriorityBadge(priority: _todo.priority),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Deadline',
            child: Text(
              DateFormatter.formatDateTime(_todo.deadline),
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.timer_rounded,
            label: 'Waktu Tersisa',
            child: Text(
              DateFormatter.getRelativeTime(_todo.deadline),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: DateFormatter.isOverdue(_todo.deadline)
                    ? AppColors.error
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Dibuat',
            child: Text(
              DateFormatter.formatDateTime(_todo.createdAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'Diupdate',
            child: Text(
              DateFormatter.formatDateTime(_todo.updatedAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _toggleComplete,
            icon: Icon(
              _todo.isCompleted
                  ? Icons.restart_alt_rounded
                  : Icons.check_circle_rounded,
            ),
            label: Text(
              _todo.isCompleted ? 'Tandai Belum Selesai' : 'Tandai Selesai',
              style: AppTextStyles.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _todo.isCompleted
                  ? AppColors.warning
                  : AppColors.success,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _editTodo,
                  icon: const Icon(Icons.edit_rounded),
                  label: Text('Edit', style: AppTextStyles.buttonSmall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _deleteTodo,
                  icon: const Icon(Icons.delete_rounded),
                  label: Text('Hapus', style: AppTextStyles.buttonSmall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}