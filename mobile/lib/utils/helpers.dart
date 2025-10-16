/// Helper functions for the app
class Helpers {
  /// Format currency
  static String formatCurrency(dynamic amount, {String symbol = '₱'}) {
    if (amount == null) return '$symbol 0.00';
    final number = amount is String ? double.tryParse(amount) ?? 0 : amount.toDouble();
    return '$symbol${number.toStringAsFixed(2)}';
  }

  /// Format date
  static String formatDate(dynamic date, {String format = 'MMM dd, yyyy'}) {
    if (date == null) return 'N/A';
    
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'N/A';
    }
    
    // Simple date formatting
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day.toString().padLeft(2, '0')}, ${dateTime.year}';
  }

  /// Format date time
  static String formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    
    DateTime dt;
    if (dateTime is String) {
      dt = DateTime.tryParse(dateTime) ?? DateTime.now();
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return 'N/A';
    }
    
    final date = formatDate(dt);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    
    return '$date $hour:$minute $period';
  }

  /// Get relative time (e.g., "2 days ago")
  static String getRelativeTime(dynamic date) {
    if (date == null) return '';
    
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Calculate days until date
  static int daysUntil(dynamic date) {
    if (date == null) return 0;
    
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 0;
    }
    
    final now = DateTime.now();
    final difference = dateTime.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// Safe text parsing (replaces null with default)
  static String safeText(dynamic value, [String defaultText = 'N/A']) {
    if (value == null) return defaultText;
    String text = value.toString();
    if (text.isEmpty || text.toLowerCase() == 'null') return defaultText;
    return text;
  }

  /// Parse double safely
  static double parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse int safely
  static int parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  /// Get initials from name
  static String getInitials(String name, {int maxChars = 2}) {
    if (name.isEmpty) return '';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, maxChars.clamp(1, words[0].length)).toUpperCase();
    }
    
    return words
        .take(maxChars)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }
}
