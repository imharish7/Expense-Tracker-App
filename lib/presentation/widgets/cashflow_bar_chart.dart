import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';

class CashflowBarChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String currencySymbol;

  const CashflowBarChart({
    super.key,
    required this.transactions,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    // Calculate last 7 days of daily income and expenses
    final now = DateTime.now();
    final dayData = <DateTime, Map<String, double>>{};

    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      dayData[d] = {'income': 0.0, 'expense': 0.0};
    }

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (dayData.containsKey(txDate)) {
        if (tx.type == TransactionType.income) {
          dayData[txDate]!['income'] = (dayData[txDate]!['income'] ?? 0.0) + tx.amount;
        } else if (tx.type == TransactionType.expense) {
          dayData[txDate]!['expense'] = (dayData[txDate]!['expense'] ?? 0.0) + tx.amount;
        }
      }
    }

    final daysList = dayData.keys.toList();
    double maxY = 1000;
    for (final map in dayData.values) {
      if ((map['income'] ?? 0) > maxY) maxY = map['income']!;
      if ((map['expense'] ?? 0) > maxY) maxY = map['expense']!;
    }
    maxY = (maxY * 1.2).ceilToDouble();

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendItem('Income', AppColors.emerald),
            const SizedBox(width: 14),
            _legendItem('Expense', AppColors.roseExpense),
          ],
        ),
        const SizedBox(height: 12),

        // Bar Chart
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= daysList.length) {
                        return const SizedBox.shrink();
                      }
                      final day = daysList[index];
                      final isToday = day.day == now.day;
                      final label = isToday ? 'Today' : DateFormat('E').format(day);

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? AppColors.primaryGold : textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = daysList[groupIndex];
                    final isIncome = rodIndex == 0;
                    final title = isIncome ? 'Income' : 'Expense';
                    final dateStr = DateFormat('MMM d').format(day);
                    return BarTooltipItem(
                      '$dateStr\n$title: ${CurrencyFormatter.format(rod.toY, currencySymbol: currencySymbol, compact: true)}',
                      TextStyle(
                        color: isIncome ? AppColors.emeraldLight : AppColors.roseExpenseLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
              barGroups: List.generate(daysList.length, (index) {
                final day = daysList[index];
                final income = dayData[day]!['income']!;
                final expense = dayData[day]!['expense']!;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppColors.emerald,
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: expense,
                      color: AppColors.roseExpense,
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelLarge(color).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
