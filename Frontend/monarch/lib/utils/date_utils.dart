
class DateUtils {
  static String formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    }
  }
}
