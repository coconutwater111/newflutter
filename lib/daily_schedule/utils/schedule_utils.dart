class ScheduleUtils {
  static String formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  static String formatDateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'tasks/$year/$month/$day';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}