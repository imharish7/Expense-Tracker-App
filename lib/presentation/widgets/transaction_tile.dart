import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_item.dart';
import '../../data/models/wallet_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final WalletModel? wallet;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.wallet,
    required this.currencySymbol,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = CategoryItem.findById(transaction.categoryId);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final tileContent = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Category Icon Badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: category.color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: category.color.withAlpha(50),
                width: 1,
              ),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTypography.titleMedium(textPrimary).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      _formatDate(transaction.date),
                      style: AppTypography.bodyMedium(textMuted).copyWith(
                        fontSize: 11,
                      ),
                    ),
                    if (wallet != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                      Flexible(
                        child: Text(
                          wallet!.name,
                          style: AppTypography.bodyMedium(textMuted).copyWith(
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Amount
          _buildAmountDisplay(),
        ],
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: AppColors.roseExpense,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
        ),
        onDismissed: (_) => onDelete?.call(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: tileContent,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: tileContent,
      ),
    );
  }

  Widget _buildAmountDisplay() {
    Color color;
    String prefix;

    switch (transaction.type) {
      case TransactionType.income:
        color = AppColors.emerald;
        prefix = '+';
        break;
      case TransactionType.expense:
        color = AppColors.roseExpense;
        prefix = '-';
        break;
      case TransactionType.transfer:
        color = AppColors.primaryGold;
        prefix = '⇄ ';
        break;
    }

    final formatted = CurrencyFormatter.format(
      transaction.amount,
      currencySymbol: currencySymbol,
    );

    return Text(
      '$prefix$formatted',
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: -0.2,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    }
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
