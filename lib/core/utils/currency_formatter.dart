import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(
    double amount, {
    String currencySymbol = '\$',
    bool showSign = false,
    bool compact = false,
    int decimalDigits = 2,
  }) {
    if (compact && amount.abs() >= 1000) {
      final compactFormat = NumberFormat.compact();
      final formatted = compactFormat.format(amount.abs());
      final sign = amount < 0 ? '-' : (showSign && amount > 0 ? '+' : '');
      return '$sign$currencySymbol$formatted';
    }

    final numberFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    );

    if (amount < 0) {
      return '-${numberFormat.format(amount.abs())}';
    } else if (showSign && amount > 0) {
      return '+${numberFormat.format(amount)}';
    }
    return numberFormat.format(amount);
  }

  static String formatNumberOnly(double amount, {int decimalDigits = 2}) {
    final format = NumberFormat.decimalPattern();
    format.minimumFractionDigits = decimalDigits;
    format.maximumFractionDigits = decimalDigits;
    return format.format(amount);
  }
}
