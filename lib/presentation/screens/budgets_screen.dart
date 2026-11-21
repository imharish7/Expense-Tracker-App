import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/category_item.dart';
import '../../providers/expense_controller.dart';
import '../widgets/budget_progress_card.dart';

class BudgetsScreen extends StatelessWidget {
  final ExpenseController controller;

  const BudgetsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final totalBudget = controller.budgets.fold(0.0, (acc, b) => acc + b.monthlyLimit);
    final totalSpentInBudgetedCategories = controller.budgets.fold(0.0, (acc, b) {
      return acc + controller.getCategorySpentThisMonth(b.categoryId);
    });

    final overallRatio = totalBudget > 0 ? (totalSpentInBudgetedCategories / totalBudget) : 0.0;
    final healthScore = ((1.0 - overallRatio.clamp(0.0, 1.0)) * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Spending Limits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primaryGold,
            onPressed: () => _showSetBudgetDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Financial Health Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MONTHLY BUDGET HEALTH',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            healthScore >= 50 ? 'Disciplined Spending' : 'Exceeding Target Cap',
                            style: AppTypography.titleMedium(
                              healthScore >= 50 ? AppColors.emerald : AppColors.roseExpense,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: (healthScore >= 50 ? AppColors.emerald : AppColors.roseExpense).withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (healthScore >= 50 ? AppColors.emerald : AppColors.roseExpense).withAlpha(60),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              healthScore >= 50 ? Icons.verified_rounded : Icons.warning_rounded,
                              size: 16,
                              color: healthScore >= 50 ? AppColors.emerald : AppColors.roseExpense,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$healthScore / 100',
                              style: TextStyle(
                                color: healthScore >= 50 ? AppColors.emerald : AppColors.roseExpense,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallRatio.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        overallRatio > 1.0
                            ? AppColors.roseExpense
                            : (overallRatio > 0.8 ? AppColors.royalAmber : AppColors.emerald),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Spent: ${CurrencyFormatter.format(totalSpentInBudgetedCategories, currencySymbol: controller.currencySymbol)}',
                        style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Cap: ${CurrencyFormatter.format(totalBudget, currencySymbol: controller.currencySymbol)}',
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Active Category Budgets (${controller.budgets.length})',
              style: AppTypography.titleMedium(textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.budgets.length,
              itemBuilder: (context, index) {
                final budget = controller.budgets[index];
                final spent = controller.getCategorySpentThisMonth(budget.categoryId);

                return BudgetProgressCard(
                  budget: budget,
                  spent: spent,
                  currencySymbol: controller.currencySymbol,
                  onEdit: () => _showEditBudgetDialog(context, budget.categoryId, budget.monthlyLimit),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    String selectedCatId = CategoryItem.defaultCategories
        .firstWhere((c) => c.type == CategoryType.expense)
        .id;
    final limitController = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final expenseCategories = CategoryItem.defaultCategories
                .where((c) => c.type == CategoryType.expense)
                .toList();

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('New Category Budget', style: TextStyle(fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCatId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: expenseCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 16),
                            const SizedBox(width: 8),
                            Text(cat.name, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCatId = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: limitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Spending Cap',
                      hintText: 'e.g. 1500.00',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final limit = double.tryParse(limitController.text.trim()) ?? 0.0;
                    if (limit > 0) {
                      controller.setBudget(selectedCatId, limit);
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save Budget'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog(BuildContext context, String categoryId, double currentLimit) {
    final cat = CategoryItem.findById(categoryId);
    final limitController = TextEditingController(text: currentLimit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Edit ${cat.name} Budget', style: const TextStyle(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly Spending Cap',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final limit = double.tryParse(limitController.text.trim()) ?? 0.0;
                if (limit > 0) {
                  controller.setBudget(categoryId, limit);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
