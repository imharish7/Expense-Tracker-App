import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/budget_model.dart';
import '../mock_data.dart';

class ExpenseRepository {
  final SharedPreferences _prefs;

  ExpenseRepository(this._prefs);

  static Future<ExpenseRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Clean up any legacy v1 mock keys to guarantee zero pre-registered balance
    prefs.remove('luxespend_transactions_v1');
    prefs.remove('luxespend_wallets_v1');
    prefs.remove('luxespend_budgets_v1');
    return ExpenseRepository(prefs);
  }

  // --- Transactions ---
  List<TransactionModel> loadTransactions() {
    final raw = _prefs.getString(AppConstants.prefsTransactionsKey);
    if (raw == null || raw.isEmpty) {
      final initial = MockData.initialTransactions;
      saveTransactions(initial);
      return initial;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (_) {
      return MockData.initialTransactions;
    }
  }

  Future<void> saveTransactions(List<TransactionModel> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.prefsTransactionsKey, raw);
  }

  // --- Wallets ---
  List<WalletModel> loadWallets() {
    final raw = _prefs.getString(AppConstants.prefsWalletsKey);
    if (raw == null || raw.isEmpty) {
      final initial = MockData.initialWallets;
      saveWallets(initial);
      return initial;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => WalletModel.fromJson(e)).toList();
    } catch (_) {
      return MockData.initialWallets;
    }
  }

  Future<void> saveWallets(List<WalletModel> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.prefsWalletsKey, raw);
  }

  // --- Budgets ---
  List<BudgetModel> loadBudgets() {
    final raw = _prefs.getString(AppConstants.prefsBudgetsKey);
    if (raw == null || raw.isEmpty) {
      final initial = MockData.initialBudgets;
      saveBudgets(initial);
      return initial;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => BudgetModel.fromJson(e)).toList();
    } catch (_) {
      return MockData.initialBudgets;
    }
  }

  Future<void> saveBudgets(List<BudgetModel> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.prefsBudgetsKey, raw);
  }

  // --- Currency ---
  String loadCurrencyCode() {
    return _prefs.getString(AppConstants.prefsCurrencyCodeKey) ?? 'USD';
  }

  Future<void> saveCurrencyCode(String code) async {
    await _prefs.setString(AppConstants.prefsCurrencyCodeKey, code);
  }

  // --- Theme Mode ---
  bool loadIsDarkMode() {
    return _prefs.getBool(AppConstants.prefsThemeKey) ?? true;
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.prefsThemeKey, isDark);
  }

  // --- Privacy Mask ---
  bool loadIsBalanceHidden() {
    return _prefs.getBool(AppConstants.prefsPrivacyKey) ?? false;
  }

  Future<void> saveIsBalanceHidden(bool hidden) async {
    await _prefs.setBool(AppConstants.prefsPrivacyKey, hidden);
  }

  // --- Reset All Data ---
  Future<void> resetAll() async {
    await _prefs.remove(AppConstants.prefsTransactionsKey);
    await _prefs.remove(AppConstants.prefsWalletsKey);
    await _prefs.remove(AppConstants.prefsBudgetsKey);
  }
}
