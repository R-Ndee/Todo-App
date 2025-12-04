import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primaryLight.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // Action Button
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specialized Empty States
class NoTodosEmpty extends StatelessWidget {
  final VoidCallback? onAddPressed;

  const NoTodosEmpty({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.task_alt_rounded,
      title: 'Belum Ada Tugas',
      message: 'Tambahkan tugas pertama Anda untuk memulai!',
      actionText: 'Tambah Tugas',
      onActionPressed: onAddPressed,
    );
  }
}

class NoSearchResultsEmpty extends StatelessWidget {
  final String searchQuery;

  const NoSearchResultsEmpty({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Tidak Ditemukan',
      message: 'Tidak ada hasil untuk "$searchQuery"',
    );
  }
}

class AllCompletedEmpty extends StatelessWidget {
  const AllCompletedEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.check_circle_outline_rounded,
      title: 'Semua Selesai! 🎉',
      message: 'Hebat! Anda telah menyelesaikan semua tugas.',
    );
  }
}

class NoCategoryTodosEmpty extends StatelessWidget {
  final String category;

  const NoCategoryTodosEmpty({
    super.key,
    required this.category,
  });

  String _getCategoryName() {
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

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.folder_open_rounded,
      title: 'Tidak Ada Tugas',
      message: 'Belum ada tugas dalam kategori ${_getCategoryName()}',
    );
  }
}

class NoTodayTodosEmpty extends StatelessWidget {
  const NoTodayTodosEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.today_rounded,
      title: 'Tidak Ada Tugas Hari Ini',
      message: 'Anda bebas untuk hari ini! 🎊',
    );
  }
}