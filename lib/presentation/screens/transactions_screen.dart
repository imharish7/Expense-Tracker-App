import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/expense_controller.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  final ExpenseController controller;

  const TransactionsScreen({super.key, required this.controller});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  String _dateFilter = 'all'; // 'all', 'month', 'week'

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions() {
    final now = DateTime.now();
    return widget.controller.transactions.where((t) {
      // Type filter
      if (_selectedTypeFilter != null && t.type != _selectedTypeFilter) {
        return false;
      }

      // Date filter
      if (_dateFilter == 'month') {
        if (t.date.year != now.year || t.date.month != now.month) return false;
      } else if (_dateFilter == 'week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        if (t.date.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))) {
          return false;
        }
      }

      // Query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchNote = t.note.toLowerCase().contains(query);
        final matchCat = t.categoryId.toLowerCase().contains(query);
        if (!matchTitle && !matchNote && !matchCat) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final filtered = _getFilteredTransactions();

    // Compute net for this filtered set
    final totalExpense = filtered
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (acc, t) => acc + t.amount);
    final totalIncome = filtered
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (acc, t) => acc + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger & Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Statement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryGold,
                  content: Text(
                    'Exported ${filtered.length} transactions as statement (CSV / PDF)',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primaryGold,
            onPressed: () => AddTransactionSheet.show(
              context,
              controller: widget.controller,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, note, or category...',
                    hintStyle: TextStyle(color: textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            color: textMuted,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Type filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _typeChip('All Types', null),
                      const SizedBox(width: 8),
                      _typeChip('Expenses', TransactionType.expense),
                      const SizedBox(width: 8),
                      _typeChip('Income', TransactionType.income),
                      const SizedBox(width: 8),
                      _typeChip('Transfers', TransactionType.transfer),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Date filter pills
                Row(
                  children: [
                    _dateChip('All Time', 'all'),
                    const SizedBox(width: 8),
                    _dateChip('This Month', 'month'),
                    const SizedBox(width: 8),
                    _dateChip('This Week', 'week'),
                  ],
                ),
              ],
            ),
          ),

          // Summary bar for current filter
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} entries',
                  style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      '+${CurrencyFormatter.format(totalIncome, currencySymbol: widget.controller.currencySymbol, compact: true)}',
                      style: const TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '-${CurrencyFormatter.format(totalExpense, currencySymbol: widget.controller.currencySymbol, compact: true)}',
                      style: const TextStyle(color: AppColors.roseExpense, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No matching transactions found.',
                          style: TextStyle(color: textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final wallet = widget.controller.getWalletById(tx.walletId);
                      return TransactionTile(
                        transaction: tx,
                        wallet: wallet,
                        currencySymbol: widget.controller.currencySymbol,
                        onDelete: () => widget.controller.deleteTransaction(tx.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, TransactionType? type) {
    final isSelected = _selectedTypeFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedTypeFilter = type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceElevated),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }

  Widget _dateChip(String label, String code) {
    final isSelected = _dateFilter == code;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _dateFilter = code),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryGold : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
        ),
      ),
    );
  }
}
