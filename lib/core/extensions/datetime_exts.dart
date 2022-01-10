extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return (day == other.day) && (year == other.year) && (month == other.month);
  }
}