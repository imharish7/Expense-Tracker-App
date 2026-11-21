import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/expense_controller.dart';
import 'dashboard_screen.dart';
import 'wallets_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_sheet.dart';

class MainNavigationScreen extends StatefulWidget {
  final ExpenseController controller;

  const MainNavigationScreen({super.key, required this.controller});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];
  DateTime? _lastBackPressTime;

  void _navigateToIndex(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _navigationHistory.add(index);
      });
    }
  }

  void _handleBackPress() {
    // 1. Pop backwards through navigation history if tabs were switched
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast();
        _currentIndex = _navigationHistory.isNotEmpty ? _navigationHistory.last : 0;
      });
      return;
    }

    // 2. If somehow history is empty but not on Overview, return to Overview
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _navigationHistory.clear();
        _navigationHistory.add(0);
      });
      return;
    }

    // 3. If already on Overview, confirm exit to prevent accidental app shutdown
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press back again to exit LuxeSpend',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.only(bottom: 84, left: 24, right: 24),
        ),
      );
      return;
    }

    // 4. Double-back verified -> gracefully exit app
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        controller: widget.controller,
        onNavigateToTransactions: () => _navigateToIndex(2),
        onNavigateToWallets: () => _navigateToIndex(1),
        onNavigateToBudgets: () => _navigateToIndex(4),
        onNavigateToSettings: () => _navigateToIndex(5),
      ),
      WalletsScreen(controller: widget.controller),
      TransactionsScreen(controller: widget.controller),
      AnalyticsScreen(controller: widget.controller),
      BudgetsScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 6,
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.black,
          shape: const CircleBorder(),
          onPressed: () => AddTransactionSheet.show(
            context,
            controller: widget.controller,
          ),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _navItem(icon: Icons.dashboard_rounded, label: 'Overview', index: 0),
                  _navItem(icon: Icons.account_balance_wallet_rounded, label: 'Accounts', index: 1),
                ],
              ),
              Row(
                children: [
                  _navItem(icon: Icons.receipt_long_rounded, label: 'Ledger', index: 2),
                  _navItem(icon: Icons.insights_rounded, label: 'Analytics', index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primaryGold
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return InkWell(
      onTap: () => _navigateToIndex(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(icon, key: ValueKey(color), color: color, size: 22),
              ),
              const SizedBox(height: 3),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
