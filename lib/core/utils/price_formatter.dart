import 'package:intl/intl.dart';

class PriceFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static String format(int price) {
    return _formatter.format(price);
  }

  static String formatCompact(int price) {
    if (price >= 1000000000) {
      return '${(price / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} triệu';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} nghìn';
    }
    return '$price đ';
  }
}
