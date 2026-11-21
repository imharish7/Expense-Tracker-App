import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_item.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final String currencySymbol;
  final VoidCallback? onEdit;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.currencySymbol,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CategoryItem.findById(budget.categoryId);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final ratio = budget.monthlyLimit > 0 ? (spent / budget.monthlyLimit) : 0.0;
    final percentage = (ratio * 100).clamp(0, 999).toDouble();
    final isOverBudget = spent > budget.monthlyLimit;
    final isNearLimit = ratio >= 0.8 && !isOverBudget;

    Color progressColor;
    if (isOverBudget) {
      progressColor = AppColors.roseExpense;
    } else if (isNearLimit) {
      progressColor = AppColors.royalAmber;
    } else {
      progressColor = category.color;
    }

    final remaining = budget.monthlyLimit - spent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverBudget
              ? AppColors.roseExpense.withAlpha(100)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isOverBudget ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category icon & title + percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTypography.titleMedium(textPrimary).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOverBudget
                          ? 'Exceeded by ${CurrencyFormatter.format(remaining.abs(), currencySymbol: currencySymbol)}'
                          : '${CurrencyFormatter.format(remaining, currencySymbol: currencySymbol)} remaining',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOverBudget ? AppColors.roseExpense : textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: progressColor.withAlpha(60)),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  color: textMuted,
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),

          // Spent vs Limit amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.format(spent, currencySymbol: currencySymbol)}',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Cap: ${CurrencyFormatter.format(budget.monthlyLimit, currencySymbol: currencySymbol)}',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
