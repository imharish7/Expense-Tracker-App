import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/expense_controller.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class WalletDetailSheet extends StatefulWidget {
  final WalletModel wallet;
  final ExpenseController controller;

  const WalletDetailSheet({
    super.key,
    required this.wallet,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required WalletModel wallet,
    required ExpenseController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WalletDetailSheet(
        wallet: wallet,
        controller: controller,
      ),
    );
  }

  @override
  State<WalletDetailSheet> createState() => _WalletDetailSheetState();
}

class _WalletDetailSheetState extends State<WalletDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    // Refresh live wallet state in case balance updated
    final liveWallet = widget.controller.getWalletById(widget.wallet.id) ?? widget.wallet;
    final walletTransactions = widget.controller.getTransactionsForWallet(liveWallet.id);
    final totalNetWorth = widget.controller.totalNetWorth;
    final shareOfTotal = totalNetWorth > 0
        ? ((liveWallet.balance / totalNetWorth) * 100).toStringAsFixed(1)
        : '0';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header: Name & Close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(liveWallet.type),
                      color: AppColors.primaryGold,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      liveWallet.name,
                      style: AppTypography.titleLarge(textPrimary).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Card Mockup
                  SizedBox(
                    width: double.infinity,
                    height: 155,
                    child: WalletCard(
                      wallet: liveWallet,
                      currencySymbol: widget.controller.currencySymbol,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Percentage of wealth & account type
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$shareOfTotal% of Total Net Worth',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${liveWallet.type.toUpperCase()} ACCOUNT',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons Row (Deposit, Withdraw, Transfer, Edit, Delete)
                  Row(
                    children: [
                      Expanded(
                        child: _actionTile(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Top Up',
                          color: AppColors.emerald,
                          isDark: isDark,
                          onTap: () => _showTopUpDialog(context, liveWallet),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionTile(
                          icon: Icons.remove_circle_outline_rounded,
                          label: 'Withdraw',
                          color: AppColors.roseExpense,
                          isDark: isDark,
                          onTap: () => _showWithdrawDialog(context, liveWallet),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionTile(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Transfer',
                          color: AppColors.primaryGold,
                          isDark: isDark,
                          onTap: () {
                            Navigator.of(context).pop();
                            AddTransactionSheet.show(
                              context,
                              controller: widget.controller,
                              initialType: TransactionType.transfer,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _actionTile(
                          icon: Icons.edit_outlined,
                          label: 'Edit Account',
                          color: AppColors.cyberCyan,
                          isDark: isDark,
                          onTap: () => _showEditWalletDialog(context, liveWallet),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionTile(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete Account',
                          color: Colors.redAccent,
                          isDark: isDark,
                          onTap: () => _confirmDeleteWallet(context, liveWallet),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account History Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Account Ledger (${walletTransactions.length})',
                        style: AppTypography.titleMedium(textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'This Account',
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Transactions List for this wallet
                  if (walletTransactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_outlined, size: 36, color: textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'No transactions linked to this account yet.',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: walletTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = walletTransactions[index];
                        return TransactionTile(
                          transaction: tx,
                          currencySymbol: widget.controller.currencySymbol,
                          onDelete: () {
                            widget.controller.deleteTransaction(tx.id);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withAlpha(50),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WalletModel wallet) {
    final amountController = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Top Up ${wallet.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add funds to this account. A corresponding income transaction will be recorded in the ledger.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount (${widget.controller.currencySymbol})',
                  prefixText: '${widget.controller.currencySymbol} ',
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
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                if (amount > 0) {
                  widget.controller.depositToWallet(
                    walletId: wallet.id,
                    amount: amount,
                  );
                  setState(() {});
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Deposit Funds'),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawDialog(BuildContext context, WalletModel wallet) {
    final amountController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Withdraw from ${wallet.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deduct funds from this account. An expense transaction will be recorded.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount (${widget.controller.currencySymbol})',
                  prefixText: '${widget.controller.currencySymbol} ',
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
                backgroundColor: AppColors.roseExpense,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                if (amount > 0) {
                  widget.controller.withdrawFromWallet(
                    walletId: wallet.id,
                    amount: amount,
                  );
                  setState(() {});
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Confirm Outflow'),
            ),
          ],
        );
      },
    );
  }

  void _showEditWalletDialog(BuildContext context, WalletModel wallet) {
    final nameController = TextEditingController(text: wallet.name);
    final cardController = TextEditingController(text: wallet.cardNumber);
    String selectedType = wallet.type;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Edit Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Account Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cardController,
                    decoration: const InputDecoration(labelText: 'Card / Reference Suffix'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Account Type'),
                    items: const [
                      DropdownMenuItem(value: 'checking', child: Text('Checking / Neobank')),
                      DropdownMenuItem(value: 'credit', child: Text('Credit Card')),
                      DropdownMenuItem(value: 'savings', child: Text('High Yield Savings')),
                      DropdownMenuItem(value: 'crypto', child: Text('Crypto / Hardware Vault')),
                      DropdownMenuItem(value: 'cash', child: Text('Physical Cash / Vault')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedType = val);
                    },
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
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      widget.controller.updateWallet(
                        id: wallet.id,
                        name: name,
                        type: selectedType,
                        cardNumber: cardController.text.trim().isEmpty
                            ? wallet.cardNumber
                            : cardController.text.trim(),
                      );
                      setState(() {});
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteWallet(BuildContext context, WalletModel wallet) {
    if (widget.controller.wallets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the only remaining account.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete ${wallet.name}?'),
          content: const Text('Are you sure you want to remove this account? This will not delete past transactions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                widget.controller.deleteWallet(wallet.id);
                Navigator.of(ctx).pop(); // pop dialog
                Navigator.of(context).pop(); // pop bottom sheet
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Icons.credit_card_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      case 'cash':
        return Icons.account_balance_wallet_rounded;
      case 'savings':
        return Icons.savings_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }
}
