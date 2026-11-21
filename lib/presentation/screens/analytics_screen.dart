import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/category_item.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/expense_controller.dart';
import '../widgets/spending_pie_chart.dart';
import '../widgets/cashflow_bar_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  final ExpenseController controller;

  const AnalyticsScreen({super.key, required this.controller});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'month'; // 'month', 'year'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final controller = widget.controller;
    final expense = controller.thisMonthExpense;
    final netSavings = controller.thisMonthNetSavings;

    final daysInCurrentMonth = DateTime.now().day;
    final avgDailySpend = daysInCurrentMonth > 0 ? (expense / daysInCurrentMonth) : 0.0;

    // Largest expense
    TransactionModel? largestExpense;
    for (final t in controller.transactions) {
      if (t.type == TransactionType.expense) {
        if (largestExpense == null || t.amount > largestExpense.amount) {
          largestExpense = t;
        }
      }
    }

    final categoryExpenses = controller.categoryExpensesThisMonth;
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                items: const [
                  DropdownMenuItem(value: 'month', child: Text('This Month')),
                  DropdownMenuItem(value: 'year', child: Text('Fiscal Year')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                _metricBox(
                  title: 'Net Cashflow',
                  value: CurrencyFormatter.format(
                    netSavings,
                    currencySymbol: controller.currencySymbol,
                    compact: true,
                    showSign: true,
                  ),
                  subtitle: '${controller.savingsRatePercentage.toStringAsFixed(0)}% Savings Rate',
                  color: netSavings >= 0 ? AppColors.emerald : AppColors.roseExpense,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
                const SizedBox(width: 12),
                _metricBox(
                  title: 'Daily Velocity',
                  value: CurrencyFormatter.format(
                    avgDailySpend,
                    currencySymbol: controller.currencySymbol,
                    compact: true,
                  ),
                  subtitle: 'Avg / day this month',
                  color: AppColors.primaryGold,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Cashflow 7-day trend card
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(22),
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
                        'Weekly Inflow vs Outflow',
                        style: AppTypography.titleMedium(textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Past 7 Days',
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CashflowBarChart(
                    transactions: controller.transactions,
                    currencySymbol: controller.currencySymbol,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Expense Breakdown Donut Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Expenditure Share',
                    style: AppTypography.titleMedium(textPrimary).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SpendingPieChart(
                    categoryExpenses: categoryExpenses,
                    currencySymbol: controller.currencySymbol,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Peak Expense Highlight
            if (largestExpense != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF271B20), const Color(0xFF191216)]
                        : [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.roseExpense.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.roseExpenseBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: AppColors.roseExpense, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LARGEST TRANSACTION THIS PERIOD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.roseExpense,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            largestExpense.title,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(
                        largestExpense.amount,
                        currencySymbol: controller.currencySymbol,
                      ),
                      style: const TextStyle(
                        color: AppColors.roseExpense,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Category Ranking List
            Text(
              'Spending by Category',
              style: AppTypography.titleMedium(textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final entry = sortedCategories[index];
                final cat = CategoryItem.findById(entry.key);
                final ratio = expense > 0 ? (entry.value / expense) : 0.0;
                final percentage = (ratio * 100).toStringAsFixed(1);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(cat.icon, color: cat.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              entry.value,
                              currencySymbol: controller.currencySymbol,
                            ),
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($percentage%)',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _metricBox({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
