class AppConstants {
  static const String appName = 'LuxeSpend';
  static const String appTagline = 'Executive Wealth & Expense Intelligence';
  
  static const String prefsTransactionsKey = 'luxespend_transactions_v2';
  static const String prefsWalletsKey = 'luxespend_wallets_v2';
  static const String prefsBudgetsKey = 'luxespend_budgets_v2';
  static const String prefsCurrencyCodeKey = 'luxespend_currency_code_v2';
  static const String prefsThemeKey = 'luxespend_theme_mode_v2';
  static const String prefsPrivacyKey = 'luxespend_privacy_v2';

  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'CAD', 'symbol': 'CA\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
  ];
}
