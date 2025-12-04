import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF4A42CC);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF99AC);
  static const Color secondaryDark = Color(0xFFCC4D68);
  
  // Background
  static const Color background = Color(0xFFF8F9FE);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color textDark = Color(0xFFFFFFFF);
  
  // Priority Colors
  static const Color priorityHigh = Color(0xFFFF4757);
  static const Color priorityMedium = Color(0xFFFFA502);
  static const Color priorityLow = Color(0xFF26DE81);
  
  // Category Colors
  static const Color categoryKuliah = Color(0xFF5F27CD);
  static const Color categoryKerja = Color(0xFF0ABDE3);
  static const Color categoryPribadi = Color(0xFFEE5A6F);
  static const Color categoryLainnya = Color(0xFF4B6584);
  
  // Status Colors
  static const Color statusPending = Color(0xFFFFA502);
  static const Color statusInProgress = Color(0xFF0ABDE3);
  static const Color statusCompleted = Color(0xFF26DE81);
  
  // Utility Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF74B9FF);
  
  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Color(0xFF2D3436);
  static const Color grey = Color(0xFFDFE6E9);
  static const Color greyLight = Color(0xFFF5F6FA);
  static const Color greyDark = Color(0xFFB2BEC3);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF26DE81), Color(0xFF20BF6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FE), Color(0xFFE8EEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return greyDark;
    }
  }

  // Get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return categoryKuliah;
      case 'kerja':
        return categoryKerja;
      case 'pribadi':
        return categoryPribadi;
      case 'lainnya':
        return categoryLainnya;
      default:
        return greyDark;
    }
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'in_progress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      default:
        return greyDark;
    }
  }
}