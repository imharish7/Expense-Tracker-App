import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/expense_repository.dart';
import '../data/mock_data.dart';

class ExpenseController extends ChangeNotifier {
  final ExpenseRepository _repository;
  final _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  List<WalletModel> _wallets = [];
  List<BudgetModel> _budgets = [];
  String _currencyCode = 'USD';
  bool _isDarkMode = true;
  bool _isBalanceHidden = false;

  ExpenseController(this._repository) {
    _loadState();
  }

  void _loadState() {
    _transactions = _repository.loadTransactions();
    _wallets = _repository.loadWallets();
    _budgets = _repository.loadBudgets();
    _currencyCode = _repository.loadCurrencyCode();
    _isDarkMode = _repository.loadIsDarkMode();
    _isBalanceHidden = _repository.loadIsBalanceHidden();
    notifyListeners();
  }

  // --- Getters ---
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<WalletModel> get wallets => List.unmodifiable(_wallets);
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  String get currencyCode => _currencyCode;
  bool get isDarkMode => _isDarkMode;
  bool get isBalanceHidden => _isBalanceHidden;

  String get currencySymbol {
    final found = AppConstants.supportedCurrencies.firstWhere(
      (c) => c['code'] == _currencyCode,
      orElse: () => {'symbol': '\$'},
    );
    return found['symbol'] ?? '\$';
  }

  // --- Financial Computations ---
  double get totalNetWorth {
    return _wallets.fold(0.0, (acc, wallet) => acc + wallet.balance);
  }

  double get thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  double get thisMonthNetSavings => thisMonthIncome - thisMonthExpense;

  double get savingsRatePercentage {
    if (thisMonthIncome <= 0) return 0.0;
    final rate = (thisMonthNetSavings / thisMonthIncome) * 100.0;
    return rate.clamp(-100.0, 100.0);
  }

  Map<String, double> get categoryExpensesThisMonth {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
      }
    }
    return map;
  }

  double getCategorySpentThisMonth(String categoryId) {
    return categoryExpensesThisMonth[categoryId] ?? 0.0;
  }

  // --- CRUD Transactions ---
  Future<void> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String categoryId,
    required String walletId,
    String? toWalletId,
    String note = '',
    bool isRecurring = false,
  }) async {
    final id = 'tx_${_uuid.v4().substring(0, 8)}';
    final tx = TransactionModel(
      id: id,
      title: title,
      amount: amount,
      date: date,
      type: type,
      categoryId: categoryId,
      walletId: walletId,
      toWalletId: toWalletId,
      note: note,
      isRecurring: isRecurring,
    );

    _transactions.insert(0, tx);

    // Apply wallet balance updates
    _updateWalletBalances(tx, reverse: false);

    await _repository.saveTransactions(_transactions);
    await _repository.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final tx = _transactions[index];
    _transactions.removeAt(index);

    // Revert wallet balance
    _updateWalletBalances(tx, reverse: true);

    await _repository.saveTransactions(_transactions);
    await _repository.saveWallets(_wallets);
    notifyListeners();
  }

  void _updateWalletBalances(TransactionModel tx, {required bool reverse}) {
    final multiplier = reverse ? -1.0 : 1.0;

    if (tx.type == TransactionType.expense) {
      final wIndex = _wallets.indexWhere((w) => w.id == tx.walletId);
      if (wIndex != -1) {
        final current = _wallets[wIndex];
        _wallets[wIndex] = current.copyWith(
          balance: current.balance - (tx.amount * multiplier),
        );
      }
    } else if (tx.type == TransactionType.income) {
      final wIndex = _wallets.indexWhere((w) => w.id == tx.walletId);
      if (wIndex != -1) {
        final current = _wallets[wIndex];
        _wallets[wIndex] = current.copyWith(
          balance: current.balance + (tx.amount * multiplier),
        );
      }
    } else if (tx.type == TransactionType.transfer && tx.toWalletId != null) {
      final fromIndex = _wallets.indexWhere((w) => w.id == tx.walletId);
      final toIndex = _wallets.indexWhere((w) => w.id == tx.toWalletId);
      if (fromIndex != -1) {
        final fromWallet = _wallets[fromIndex];
        _wallets[fromIndex] = fromWallet.copyWith(
          balance: fromWallet.balance - (tx.amount * multiplier),
        );
      }
      if (toIndex != -1) {
        final toWallet = _wallets[toIndex];
        _wallets[toIndex] = toWallet.copyWith(
          balance: toWallet.balance + (tx.amount * multiplier),
        );
      }
    }
  }

  // --- CRUD Wallets ---
  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String cardNumber,
    required List<int> gradientHexes,
  }) async {
    final id = 'w_${_uuid.v4().substring(0, 6)}';
    final wallet = WalletModel(
      id: id,
      name: name,
      type: type,
      balance: initialBalance,
      cardNumber: cardNumber,
      gradientHexes: gradientHexes,
    );
    _wallets.add(wallet);
    await _repository.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> updateWallet({
    required String id,
    required String name,
    required String type,
    required String cardNumber,
  }) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _wallets[index] = _wallets[index].copyWith(
        name: name,
        type: type,
        cardNumber: cardNumber,
      );
      await _repository.saveWallets(_wallets);
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String id) async {
    if (_wallets.length <= 1) return; // Maintain at least 1 account
    _wallets.removeWhere((w) => w.id == id);
    await _repository.saveWallets(_wallets);
    notifyListeners();
  }

  Future<void> depositToWallet({
    required String walletId,
    required double amount,
    String note = 'Deposit / Balance Top Up',
  }) async {
    final wallet = getWalletById(walletId);
    if (wallet == null) return;
    await addTransaction(
      title: 'Top Up: ${wallet.name}',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.income,
      categoryId: 'salary',
      walletId: walletId,
      note: note,
    );
  }

  Future<void> withdrawFromWallet({
    required String walletId,
    required double amount,
    String note = 'Manual Withdrawal / Cash Out',
  }) async {
    final wallet = getWalletById(walletId);
    if (wallet == null) return;
    await addTransaction(
      title: 'Withdrawal: ${wallet.name}',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.expense,
      categoryId: 'services',
      walletId: walletId,
      note: note,
    );
  }

  List<TransactionModel> getTransactionsForWallet(String walletId) {
    return _transactions
        .where((t) => t.walletId == walletId || t.toWalletId == walletId)
        .toList();
  }

  WalletModel? getWalletById(String id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return _wallets.isNotEmpty ? _wallets.first : null;
    }
  }

  // --- CRUD Budgets ---
  Future<void> setBudget(String categoryId, double monthlyLimit) async {
    final index = _budgets.indexWhere((b) => b.categoryId == categoryId);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(monthlyLimit: monthlyLimit);
    } else {
      _budgets.add(BudgetModel(
        id: 'b_${_uuid.v4().substring(0, 6)}',
        categoryId: categoryId,
        monthlyLimit: monthlyLimit,
      ));
    }
    await _repository.saveBudgets(_budgets);
    notifyListeners();
  }

  BudgetModel? getBudgetForCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  // --- Settings & Toggles ---
  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    await _repository.saveCurrencyCode(code);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _repository.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> togglePrivacy() async {
    _isBalanceHidden = !_isBalanceHidden;
    await _repository.saveIsBalanceHidden(_isBalanceHidden);
    notifyListeners();
  }

  Future<void> resetToSampleData() async {
    await _repository.resetAll();
    _transactions = MockData.initialTransactions;
    _wallets = MockData.initialWallets;
    _budgets = MockData.initialBudgets;
    await _repository.saveTransactions(_transactions);
    await _repository.saveWallets(_wallets);
    await _repository.saveBudgets(_budgets);
    notifyListeners();
  }
}
