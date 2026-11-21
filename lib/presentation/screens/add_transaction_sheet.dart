import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/category_item.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../providers/expense_controller.dart';

class AddTransactionSheet extends StatefulWidget {
  final ExpenseController controller;
  final TransactionType initialType;

  const AddTransactionSheet({
    super.key,
    required this.controller,
    this.initialType = TransactionType.expense,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseController controller,
    TransactionType initialType = TransactionType.expense,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionSheet(
        controller: controller,
        initialType: initialType,
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late TransactionType _type;
  late String _selectedWalletId;
  String? _selectedToWalletId;
  late String _selectedCategoryId;
  late DateTime _selectedDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _amountString = '0';

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;

    final wallets = widget.controller.wallets;
    _selectedWalletId = wallets.isNotEmpty ? wallets.first.id : 'w1';
    if (wallets.length > 1) {
      _selectedToWalletId = wallets[1].id;
    }

    _selectedCategoryId = _type == TransactionType.income ? 'salary' : 'dining';
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.disposeWidget();
    _noteController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    return double.tryParse(_amountString) ?? 0.0;
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_amountString == '0' && digit != '.') {
        _amountString = digit;
      } else if (digit == '.' && _amountString.contains('.')) {
        return; // prevent multiple dots
      } else {
        if (_amountString.contains('.')) {
          final parts = _amountString.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return; // max 2 decimals
        }
        _amountString += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_amountString.length > 1) {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      } else {
        _amountString = '0';
      }
    });
  }

  void _addQuickAmount(double amount) {
    setState(() {
      final current = double.tryParse(_amountString) ?? 0.0;
      _amountString = CurrencyFormatter.formatNumberOnly(current + amount, decimalDigits: 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final availableCategories = CategoryItem.defaultCategories
        .where((c) =>
            _type == TransactionType.income
                ? c.type == CategoryType.income
                : c.type == CategoryType.expense)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
          // Drag Handle
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

          // Header: Title & Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Transaction',
                  style: AppTypography.titleLarge(textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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

          // Scrollable Form & Keypad
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Type Segmented Switcher
                  _buildTypeSegmentedControl(isDark),
                  const SizedBox(height: 18),

                  // Big Amount Display
                  _buildAmountDisplay(textPrimary, textMuted),
                  const SizedBox(height: 12),

                  // Quick Amount Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _quickChip('+\$10', 10),
                      const SizedBox(width: 8),
                      _quickChip('+\$50', 50),
                      const SizedBox(width: 8),
                      _quickChip('+\$100', 100),
                      const SizedBox(width: 8),
                      _quickChip('+\$500', 500),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Custom Tactile Number Keypad
                  _buildKeypad(isDark, textPrimary),
                  const SizedBox(height: 18),

                  // Title / Merchant input
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Title / Merchant',
                      labelStyle: TextStyle(color: textMuted, fontSize: 13),
                      hintText: _type == TransactionType.income
                          ? 'e.g. Consulting Invoice #104'
                          : 'e.g. Nobu Downtown',
                      hintStyle: TextStyle(color: textMuted.withAlpha(120), fontSize: 13),
                      prefixIcon: Icon(Icons.edit_note_rounded, color: textMuted),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector (if not transfer)
                  if (_type != TransactionType.transfer) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category',
                        style: AppTypography.titleMedium(textPrimary).copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableCategories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = availableCategories[index];
                          final isSelected = cat.id == _selectedCategoryId;

                          return InkWell(
                            onTap: () => setState(() => _selectedCategoryId = cat.id),
                            borderRadius: BorderRadius.circular(22),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cat.color.withAlpha(40)
                                    : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? cat.color : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon, color: isSelected ? cat.color : textMuted, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected ? cat.color : textPrimary,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Account / Wallet Pickers
                  _buildWalletSelector(isDark, textPrimary, textMuted),
                  const SizedBox(height: 14),

                  // Date Picker Row
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: textMuted, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Transaction Date',
                                style: TextStyle(color: textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _segmentTab('Expense', TransactionType.expense, AppColors.roseExpense),
          _segmentTab('Income', TransactionType.income, AppColors.emerald),
          _segmentTab('Transfer', TransactionType.transfer, AppColors.primaryGold),
        ],
      ),
    );
  }

  Widget _segmentTab(String label, TransactionType type, Color activeColor) {
    final isSelected = _type == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _type = type;
            if (type == TransactionType.income) {
              _selectedCategoryId = 'salary';
            } else if (type == TransactionType.expense) {
              _selectedCategoryId = 'dining';
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(Color textPrimary, Color textMuted) {
    Color color;
    if (_type == TransactionType.expense) {
      color = AppColors.roseExpense;
    } else if (_type == TransactionType.income) {
      color = AppColors.emerald;
    } else {
      color = AppColors.primaryGold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'ENTER AMOUNT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.controller.currencySymbol,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _amountString,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _addQuickAmount(amount),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated.withAlpha(120) : AppColors.lightSurfaceElevated.withAlpha(120),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _keypadButton('1', textPrimary),
              _keypadButton('2', textPrimary),
              _keypadButton('3', textPrimary),
            ],
          ),
          Row(
            children: [
              _keypadButton('4', textPrimary),
              _keypadButton('5', textPrimary),
              _keypadButton('6', textPrimary),
            ],
          ),
          Row(
            children: [
              _keypadButton('7', textPrimary),
              _keypadButton('8', textPrimary),
              _keypadButton('9', textPrimary),
            ],
          ),
          Row(
            children: [
              _keypadButton('.', textPrimary),
              _keypadButton('0', textPrimary),
              _keypadIconButton(Icons.backspace_outlined, textPrimary, _backspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keypadButton(String digit, Color textColor) {
    return Expanded(
      child: InkWell(
        onTap: () => _appendDigit(digit),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypadIconButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildWalletSelector(bool isDark, Color textPrimary, Color textMuted) {
    final wallets = widget.controller.wallets;

    if (_type == TransactionType.transfer) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From Account', style: TextStyle(color: textMuted, fontSize: 12)),
                const SizedBox(height: 6),
                _dropdownWallet(wallets, _selectedWalletId, (val) {
                  if (val != null) setState(() => _selectedWalletId = val);
                }, isDark, textPrimary),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To Account', style: TextStyle(color: textMuted, fontSize: 12)),
                const SizedBox(height: 6),
                _dropdownWallet(wallets, _selectedToWalletId ?? wallets.first.id, (val) {
                  if (val != null) setState(() => _selectedToWalletId = val);
                }, isDark, textPrimary),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Account', style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        _dropdownWallet(wallets, _selectedWalletId, (val) {
          if (val != null) setState(() => _selectedWalletId = val);
        }, isDark, textPrimary),
      ],
    );
  }

  Widget _dropdownWallet(
    List<WalletModel> wallets,
    String currentValue,
    ValueChanged<String?> onChanged,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: wallets.any((w) => w.id == currentValue) ? currentValue : wallets.first.id,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          items: wallets.map((w) {
            return DropdownMenuItem<String>(
              value: w.id,
              child: Text(
                w.name,
                style: TextStyle(color: textPrimary, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: AppColors.primaryGold.withAlpha(120),
        ),
        onPressed: _saveTransaction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Confirm Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amount = _currentAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than zero.')),
      );
      return;
    }

    String title = _titleController.text.trim();
    if (title.isEmpty) {
      if (_type == TransactionType.transfer) {
        title = 'Account Transfer';
      } else {
        final cat = CategoryItem.findById(_selectedCategoryId);
        title = cat.name;
      }
    }

    widget.controller.addTransaction(
      title: title,
      amount: amount,
      date: _selectedDate,
      type: _type,
      categoryId: _type == TransactionType.transfer ? 'services' : _selectedCategoryId,
      walletId: _selectedWalletId,
      toWalletId: _type == TransactionType.transfer ? _selectedToWalletId : null,
      note: _noteController.text.trim(),
    );

    Navigator.of(context).pop();
  }
}

extension on TextEditingController {
  void disposeWidget() {
    dispose();
  }
}
