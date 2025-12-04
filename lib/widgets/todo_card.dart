import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/todo_model.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../utils/date_formatter.dart';
import 'priority_badge.dart';
import 'category_chip.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateFormatter.isOverdue(todo.deadline) && !todo.isCompleted;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete_rounded,
            label: 'Hapus',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: isOverdue
              ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  _buildCheckbox(),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: todo.isCompleted
                              ? AppTextStyles.strikethrough
                              : AppTextStyles.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Description
                        if (todo.description != null && todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description!,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Tags & Info
                        Row(
                          children: [
                            CategoryChip(
                              category: todo.category,
                              isSmall: true,
                            ),
                            const SizedBox(width: 8),
                            PriorityBadge(
                              priority: todo.priority,
                              isSmall: true,
                            ),
                            const Spacer(),
                            _buildDeadlineInfo(),
                          ],
                        ),
                      ],
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

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onComplete,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: todo.isCompleted
                ? AppColors.success
                : AppColors.getPriorityColor(todo.priority),
            width: 2,
          ),
          color: todo.isCompleted ? AppColors.success : Colors.transparent,
        ),
        child: todo.isCompleted
            ? const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildDeadlineInfo() {
    final isOverdue = DateFormatter.isOverdue(todo.deadline) && !todo.isCompleted;
    final countdown = DateFormatter.getCountdown(todo.deadline);
    
    Color getDeadlineColor() {
      if (todo.isCompleted) return AppColors.textLight;
      if (isOverdue) return AppColors.error;
      if (countdown.contains('h') && int.parse(countdown.replaceAll('h', '')) <= 1) {
        return AppColors.warning;
      }
      return AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getDeadlineColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.error_outline_rounded : Icons.schedule_rounded,
            size: 12,
            color: getDeadlineColor(),
          ),
          const SizedBox(width: 4),
          Text(
            isOverdue ? 'Terlambat' : countdown,
            style: AppTextStyles.badge.copyWith(
              color: getDeadlineColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact version for list view
class CompactTodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const CompactTodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.isCompleted
                            ? AppColors.success
                            : AppColors.textLight,
                        width: 2,
                      ),
                      color: todo.isCompleted ? AppColors.success : Colors.transparent,
                    ),
                    child: todo.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: todo.isCompleted
                        ? AppTextStyles.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textLight,
                          )
                        : AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                PriorityDot(priority: todo.priority),
              ],
            ),
          ),
        ),
      ),
    );
  }
}