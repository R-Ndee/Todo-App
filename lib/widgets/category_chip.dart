import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSmall;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSmall = false,
  });

  String _getCategoryText() {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return 'Kuliah';
      case 'kerja':
        return 'Kerja';
      case 'pribadi':
        return 'Pribadi';
      case 'lainnya':
        return 'Lainnya';
      default:
        return category;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return Icons.school_rounded;
      case 'kerja':
        return Icons.work_rounded;
      case 'pribadi':
        return Icons.person_rounded;
      case 'lainnya':
        return Icons.more_horiz_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: isSmall ? 12 : 14,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getCategoryText(),
            style: (isSmall ? AppTextStyles.badge : AppTextStyles.chip).copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Category Selector for forms
class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildCategoryOption('kuliah', 'Kuliah', Icons.school_rounded),
            const SizedBox(width: 8),
            _buildCategoryOption('kerja', 'Kerja', Icons.work_rounded),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCategoryOption('pribadi', 'Pribadi', Icons.person_rounded),
            const SizedBox(width: 8),
            _buildCategoryOption('lainnya', 'Lainnya', Icons.more_horiz_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryOption(String value, String label, IconData icon) {
    final isSelected = selectedCategory == value;
    final color = AppColors.getCategoryColor(value);

    return Expanded(
      child: InkWell(
        onTap: () => onCategoryChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.greyLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
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

// Filter Chip for home screen
class FilterCategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _getCategoryText() {
    switch (category.toLowerCase()) {
      case 'all':
        return 'Semua';
      case 'kuliah':
        return 'Kuliah';
      case 'kerja':
        return 'Kerja';
      case 'pribadi':
        return 'Pribadi';
      case 'lainnya':
        return 'Lainnya';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = category == 'all' 
        ? AppColors.primary 
        : AppColors.getCategoryColor(category);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.greyLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          _getCategoryText(),
          style: AppTextStyles.chip.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}