import 'package:intl/intl.dart';

class DateHelper {
  static String formatChatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return DateFormat('h:mm a').format(dateTime);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEEE').format(dateTime);
    return DateFormat('MMM d').format(dateTime);
  }

  static String formatMeetupDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d • h:mm a').format(dateTime);
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  static String formatMessageGroupDate(DateTime dateTime) {
    if (isToday(dateTime)) return 'Today';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}