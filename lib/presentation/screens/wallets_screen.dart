import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/expense_controller.dart';
import '../widgets/wallet_card.dart';
import 'add_transaction_sheet.dart';
import 'wallet_detail_sheet.dart';

class WalletsScreen extends StatelessWidget {
  final ExpenseController controller;

  const WalletsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final totalBalance = controller.totalNetWorth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts & Liquidity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primaryGold,
            onPressed: () => _showAddWalletDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.cardDarkGradient,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primaryGold.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ACCOUNTS VALUE',
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(
                      totalBalance,
                      currencySymbol: controller.currencySymbol,
                    ),
                    style: AppTypography.currency(
                      Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(25),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.white.withAlpha(40)),
                    ),
                    onPressed: () => AddTransactionSheet.show(
                      context,
                      controller: controller,
                      initialType: TransactionType.transfer,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primaryGold),
                    label: const Text('Transfer Funds Between Accounts', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hint Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGold.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: AppColors.primaryGold, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap any account to Top Up, Withdraw, Transfer, or view its ledger.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Wallets list
            Text(
              'Configured Wallets & Cards (${controller.wallets.length})',
              style: AppTypography.titleMedium(textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.wallets.length,
              itemBuilder: (context, index) {
                final wallet = controller.wallets[index];
                final shareOfTotal = totalBalance > 0
                    ? ((wallet.balance / totalBalance) * 100).toStringAsFixed(1)
                    : '0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 155,
                        child: WalletCard(
                          wallet: wallet,
                          currencySymbol: controller.currencySymbol,
                          onTap: () => WalletDetailSheet.show(
                            context,
                            wallet: wallet,
                            controller: controller,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share of Liquidity: $shareOfTotal%',
                              style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                _miniActionButton(
                                  icon: Icons.add_rounded,
                                  label: 'Top Up',
                                  color: AppColors.emerald,
                                  onTap: () => WalletDetailSheet.show(
                                    context,
                                    wallet: wallet,
                                    controller: controller,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _miniActionButton(
                                  icon: Icons.receipt_long_rounded,
                                  label: 'Manage',
                                  color: AppColors.primaryGold,
                                  onTap: () => WalletDetailSheet.show(
                                    context,
                                    wallet: wallet,
                                    controller: controller,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _miniActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final cardController = TextEditingController(text: '•••• 1234');
    String selectedType = 'checking';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Add Account / Wallet', style: TextStyle(fontWeight: FontWeight.w700)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account / Wallet Name',
                        hintText: 'e.g. Goldman Sachs Yield',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Starting Balance',
                        hintText: 'e.g. 5000.00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cardController,
                      decoration: const InputDecoration(
                        labelText: 'Card / Reference Suffix',
                        hintText: 'e.g. •••• 9921',
                      ),
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
                    final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
                    if (name.isEmpty) return;

                    controller.addWallet(
                      name: name,
                      type: selectedType,
                      initialBalance: balance,
                      cardNumber: cardController.text.trim().isEmpty
                          ? '•••• 0000'
                          : cardController.text.trim(),
                      gradientHexes: [0xFF0F766E, 0xFF115E59],
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Add Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
