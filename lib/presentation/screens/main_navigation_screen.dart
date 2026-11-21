import 'package:flutter/material.dart';
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

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
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

    return Scaffold(
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
