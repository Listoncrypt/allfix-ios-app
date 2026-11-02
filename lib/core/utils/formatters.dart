import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _nairaFormat = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
    locale: 'en_NG',
  );

  /// Format an integer or double to Nigerian Naira string e.g. ₦180,000,000
  static String formatNaira(num amount) {
    return _nairaFormat.format(amount);
  }

  /// Format ISO Date string to human readable format
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return isoString;
    }
  }

  /// Format simple date
  static String formatSimpleDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
