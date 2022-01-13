import 'package:intl/intl.dart';

final DateFormat f1 = DateFormat("HH:mm");
final DateFormat f2 = DateFormat("HH:mm dd/MM/yyyy");

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return (day == other.day) && (year == other.year) && (month == other.month);
  }

  String toMyDateTime() {
    final now = DateTime.now();
    if(now.isSameDay(this)) {
      return f1.format(this);
    } else {
      return f2.format(this);
    }
  }
}