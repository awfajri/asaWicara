import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String formatFullDateTime(DateTime dt) {
    try {
      return DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    }
  }

  static String formatDateOnly(DateTime dt) {
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }

  static String formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins == 0) return '$secs detik';
    return '$mins menit $secs detik';
  }
}
