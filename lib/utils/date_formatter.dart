import 'package:intl/intl.dart';

class DateFormatter {
  // Format: 25 Des 2024
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // Format: 14:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Format: 25 Des 2024, 14:30
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  // Format: Senin, 25 Des
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, dd MMM', 'id_ID').format(date);
  }

  // Format: Senin
  static String formatDay(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  // Relative time
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      // Past
      final absDiff = difference.abs();
      if (absDiff.inDays > 0) {
        return '${absDiff.inDays} hari yang lalu';
      } else if (absDiff.inHours > 0) {
        return '${absDiff.inHours} jam yang lalu';
      } else if (absDiff.inMinutes > 0) {
        return '${absDiff.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } else {
      // Future
      if (difference.inDays > 0) {
        return '${difference.inDays} hari lagi';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam lagi';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit lagi';
      } else {
        return 'Sebentar lagi';
      }
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Smart date format
  static String smartFormat(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini, ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Besok, ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Kemarin, ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  // Countdown text
  static String getCountdown(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Terlambat';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Segera!';
    }
  }

  // Check if overdue
  static bool isOverdue(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }

  // Get deadline status color indicator
  static String getDeadlineStatus(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'overdue';
    } else if (difference.inHours < 24) {
      return 'urgent';
    } else if (difference.inDays < 3) {
      return 'soon';
    } else {
      return 'normal';
    }
  }

  // Format for display in list
  static String formatForList(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini • ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Besok • ${formatTime(date)}';
    } else {
      final diff = date.difference(DateTime.now()).inDays;
      if (diff > 0 && diff <= 7) {
        return '${formatDay(date)} • ${formatTime(date)}';
      } else {
        return formatDateTime(date);
      }
    }
  }
}