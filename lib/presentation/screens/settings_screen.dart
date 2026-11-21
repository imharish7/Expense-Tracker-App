import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/expense_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ExpenseController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Developer / Portfolio Showcase Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withAlpha(60),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.code_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'COMMERCIAL PORTFOLIO PIECE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'LuxeSpend • Executive Wealth Suite',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Engineered with Clean Architecture, Reactive State Controller, Offline-First Persistence, and Interactive fl_chart Visualizations.',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences Section
            Text(
              'APPLICATION PREFERENCES',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Currency Picker
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primaryGold),
                      title: Text('Active Currency', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('${controller.currencyCode} (${controller.currencySymbol})', style: TextStyle(color: textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => _showCurrencyPicker(context),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

                    // Dark / Light Theme
                    SwitchListTile(
                      secondary: Icon(
                        controller.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primaryGold,
                      ),
                      title: Text('Obsidian Dark Mode', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Switch between luxury dark and clean light', style: TextStyle(color: textMuted, fontSize: 12)),
                      value: controller.isDarkMode,
                      activeThumbColor: AppColors.primaryGold,
                      onChanged: (_) => controller.toggleTheme(),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

                    // Privacy Shield
                    SwitchListTile(
                      secondary: const Icon(Icons.security_rounded, color: AppColors.primaryGold),
                      title: Text('Privacy Shield', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Mask account balances on home screen', style: TextStyle(color: textMuted, fontSize: 12)),
                      value: controller.isBalanceHidden,
                      activeThumbColor: AppColors.primaryGold,
                      onChanged: (_) => controller.togglePrivacy(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data & Storage Section
            Text(
              'DATA & SYSTEM RECOVERY',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh_rounded, color: AppColors.emerald),
                      title: Text('Clear Data & Reset to Zero Balance', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Zeros all account balances and clears all transactions', style: TextStyle(color: textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        controller.resetToSampleData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All balances and transactions reset to zero.'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Primary Currency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: AppConstants.supportedCurrencies.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  itemBuilder: (context, index) {
                    final curr = AppConstants.supportedCurrencies[index];
                    final isSelected = curr['code'] == controller.currencyCode;

                    return ListTile(
                      title: Text('${curr['name']} (${curr['code']})'),
                      trailing: Text(
                        curr['symbol'] ?? '',
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryGold : null,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        controller.setCurrency(curr['code']!);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
