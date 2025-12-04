import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool isSmall;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  String _getPriorityText() {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return priority;
    }
  }

  IconData _getPriorityIcon() {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.arrow_upward_rounded;
      case 'medium':
        return Icons.drag_handle_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPriorityColor(priority);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: isSmall ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityText(),
            style: (isSmall ? AppTextStyles.badge : AppTextStyles.chip).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Priority Dot Indicator (for minimal display)
class PriorityDot extends StatelessWidget {
  final String priority;
  final double size;

  const PriorityDot({
    super.key,
    required this.priority,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPriorityColor(priority);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// Priority Selector for forms
class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityOption('high', 'Tinggi', Icons.arrow_upward_rounded),
        const SizedBox(width: 8),
        _buildPriorityOption('medium', 'Sedang', Icons.drag_handle_rounded),
        const SizedBox(width: 8),
        _buildPriorityOption('low', 'Rendah', Icons.arrow_downward_rounded),
      ],
    );
  }

  Widget _buildPriorityOption(String value, String label, IconData icon) {
    final isSelected = selectedPriority == value;
    final color = AppColors.getPriorityColor(value);

    return Expanded(
      child: InkWell(
        onTap: () => onPriorityChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : AppColors.greyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}