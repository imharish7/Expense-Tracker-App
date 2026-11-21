import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/expense_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_stat_chip.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/spending_pie_chart.dart';
import 'add_transaction_sheet.dart';
import 'wallet_detail_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final ExpenseController controller;
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToWallets;
  final VoidCallback onNavigateToBudgets;
  final VoidCallback onNavigateToSettings;

  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onNavigateToTransactions,
    required this.onNavigateToWallets,
    required this.onNavigateToBudgets,
    required this.onNavigateToSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final recentTransactions = controller.transactions.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Executive Greeting & Actions
              _buildTopBar(context, textPrimary, textMuted),
              const SizedBox(height: 18),

              // Hero Net Worth & Actions Card
              BalanceCard(
                totalBalance: controller.totalNetWorth,
                monthlyIncome: controller.thisMonthIncome,
                monthlyExpense: controller.thisMonthExpense,
                currencySymbol: controller.currencySymbol,
                isHidden: controller.isBalanceHidden,
                onToggleHidden: controller.togglePrivacy,
                onAddExpense: () => AddTransactionSheet.show(
                  context,
                  controller: controller,
                  initialType: TransactionType.expense,
                ),
                onAddIncome: () => AddTransactionSheet.show(
                  context,
                  controller: controller,
                  initialType: TransactionType.income,
                ),
                onTransfer: () => AddTransactionSheet.show(
                  context,
                  controller: controller,
                  initialType: TransactionType.transfer,
                ),
              ),
              const SizedBox(height: 18),

              // Quick Key Performance Indicators
              Row(
                children: [
                  QuickStatChip(
                    label: 'Net Savings',
                    value: CurrencyFormatter.format(
                      controller.thisMonthNetSavings,
                      currencySymbol: controller.currencySymbol,
                      compact: true,
                    ),
                    icon: Icons.savings_rounded,
                    iconColor: controller.thisMonthNetSavings >= 0
                        ? AppColors.emerald
                        : AppColors.roseExpense,
                  ),
                  const SizedBox(width: 10),
                  QuickStatChip(
                    label: 'Savings Rate',
                    value: '${controller.savingsRatePercentage.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.primaryGold,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Accounts & Wallets Carousel Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accounts & Liquidity',
                    style: AppTypography.titleMedium(textPrimary).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToWallets,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 155,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = controller.wallets[index];
                    return WalletCard(
                      wallet: wallet,
                      currencySymbol: controller.currencySymbol,
                      onTap: () => WalletDetailSheet.show(
                        context,
                        wallet: wallet,
                        controller: controller,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 26),

              // Spending Breakdown Donut
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Expense Allocation',
                          style: AppTypography.titleMedium(textPrimary).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Active Month',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SpendingPieChart(
                      categoryExpenses: controller.categoryExpensesThisMonth,
                      currencySymbol: controller.currencySymbol,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.titleMedium(textPrimary).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToTransactions,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recent Transactions List
              if (recentTransactions.isEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: textMuted),
                      const SizedBox(height: 10),
                      Text(
                        'No transactions recorded yet',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to record your first income, expense, or transfer.',
                        style: TextStyle(color: textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = recentTransactions[index];
                    final wallet = controller.getWalletById(tx.walletId);
                    return TransactionTile(
                      transaction: tx,
                      wallet: wallet,
                      currencySymbol: controller.currencySymbol,
                      onDelete: () => controller.deleteTransaction(tx.id),
                    );
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color textPrimary, Color textMuted) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                border: Border.all(color: Colors.white.withAlpha(50), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.person_outline_rounded, color: Colors.black, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Portfolio Executive',
                  style: AppTypography.titleMedium(textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Budgets Shortcut
            IconButton(
              icon: Icon(Icons.pie_chart_outline_rounded, color: textPrimary, size: 20),
              tooltip: 'Budgets',
              onPressed: onNavigateToBudgets,
            ),
            // Settings Shortcut
            IconButton(
              icon: Icon(Icons.settings_outlined, color: textPrimary, size: 20),
              tooltip: 'Settings',
              onPressed: onNavigateToSettings,
            ),
            // Dark / Light Mode Toggle
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: textPrimary,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: controller.toggleTheme,
            ),
          ],
        ),
      ],
    );
  }
}
