import 'package:intl/intl.dart';

/// Utility class for handling DateTime conversions between UTC and local time
/// for consistent API communication with Traccar server
class DateTimeHelper {
  
  /// Convert local DateTime to UTC for API requests
  /// Use this when sending datetime to the server
  static String toUtcString(DateTime localDateTime) {
    return localDateTime.toUtc().toIso8601String();
  }
  
  /// Parse UTC datetime string from server and convert to local time
  /// Use this when receiving datetime from the server
  static DateTime? fromUtcString(String? utcDateTimeString) {
    if (utcDateTimeString == null || utcDateTimeString.isEmpty) {
      return null;
    }
    
    try {
      // Parse the UTC datetime and convert to local
      DateTime utcDateTime = DateTime.parse(utcDateTimeString);
      return utcDateTime.toLocal();
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }
  
  /// Safe parse method that tries to parse and convert to local
  /// Similar to DateTime.tryParse but always converts to local
  static DateTime? tryParseToLocal(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }
    
    try {
      DateTime parsedDateTime = DateTime.parse(dateTimeString);
      // If the parsed datetime is already in UTC, convert to local
      // If it's already local, keep it as is
      return parsedDateTime.isUtc ? parsedDateTime.toLocal() : parsedDateTime;
    } catch (e) {
      return null;
    }
  }
  
  /// Convert DateTime to ISO string for JSON serialization
  /// Automatically converts to UTC before serialization
  static String? toJsonString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toUtc().toIso8601String();
  }
  
  /// Parse DateTime from JSON and convert to local time
  /// Automatically converts from UTC to local after parsing
  static DateTime? fromJsonString(String? jsonDateTimeString) {
    return fromUtcString(jsonDateTimeString);
  }
  
  /// Get current UTC time as ISO string for API requests
  static String nowUtc() {
    return DateTime.now().toUtc().toIso8601String();
  }
  
  /// Get current local time
  static DateTime nowLocal() {
    return DateTime.now();
  }
  
  /// Format local datetime for display in UI
  static String formatLocal(DateTime? dateTime, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    if (dateTime == null) return '';
    
    // Ensure we're working with local time
    DateTime localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat(pattern).format(localDateTime);
  }
  
  /// Format duration in a human-readable format
  static String formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) return 'N/A';
    
    int seconds = durationInSeconds % 60;
    int minutes = (durationInSeconds ~/ 60) % 60;
    int hours = durationInSeconds ~/ 3600;
    
    return '${hours.toString().padLeft(2, '0')}h '
           '${minutes.toString().padLeft(2, '0')}m '
           '${seconds.toString().padLeft(2, '0')}s';
  }
  
  /// Calculate time difference for "time ago" display
  static String timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    // Ensure we're working with local time
    DateTime localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  /// Validate if a date range is valid (start <= end)
  static bool isValidDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return start.isBefore(end) || start.isAtSameMomentAs(end);
  }
  
  /// Get start of day for a given date in local time
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day for a given date in local time
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Format datetime string for reports display
  /// This method is commonly used across report widgets
  static String formatForReports(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return dateTimeStr ?? '';
    
    try {
      final dateTime = fromUtcString(dateTimeStr);
      if (dateTime == null) return dateTimeStr;
      
      return formatLocal(dateTime, pattern: 'dd/MM/yyyy HH:mm');
    } catch (e) {
      return dateTimeStr;
    }
  }
}
