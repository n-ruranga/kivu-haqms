/// Small date/time formatting helpers.
///
/// The project deliberately avoids adding `intl` for a handful of labels, so
/// these cover the English formats the booking and schedule screens need.
abstract final class AppDateFormat {
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _monthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// 'Mon'
  static String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

  /// 'Jul'
  static String monthShort(DateTime date) => _monthsShort[date.month - 1];

  /// '28 July 2026'
  static String fullDate(DateTime date) =>
      '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';

  /// 'Today' / 'Tomorrow' / 'Mon, 28 Jul'
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    return '${weekdayShort(date)}, ${date.day} ${monthShort(date)}';
  }

  /// '09:30' -> '9:30 AM'
  static String slotLabel(String slot) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $period';
  }

  /// 'Tomorrow at 9:30 AM'
  static String relativeDateTime(DateTime date, String slot) =>
      '${relativeDate(date)} at ${slotLabel(slot)}';
}
