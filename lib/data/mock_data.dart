import 'models/wallet_model.dart';
import 'models/transaction_model.dart';
import 'models/budget_model.dart';

class MockData {
  static List<WalletModel> get initialWallets => [
        const WalletModel(
          id: 'w1',
          name: 'Primary Checking',
          type: 'checking',
          balance: 0.00,
          cardNumber: '•••• 8842',
          gradientHexes: [0xFF1E293B, 0xFF0F172A],
        ),
        const WalletModel(
          id: 'w2',
          name: 'Savings Vault',
          type: 'savings',
          balance: 0.00,
          cardNumber: '•••• 5190',
          gradientHexes: [0xFFE5B869, 0xFF996B1E],
        ),
        const WalletModel(
          id: 'w3',
          name: 'Cold Storage Vault',
          type: 'crypto',
          balance: 0.00,
          cardNumber: '•••• 0x9F',
          gradientHexes: [0xFF8B5CF6, 0xFF4C1D95],
        ),
        const WalletModel(
          id: 'w4',
          name: 'Physical Cash Reserve',
          type: 'cash',
          balance: 0.00,
          cardNumber: '•••• CASH',
          gradientHexes: [0xFF059669, 0xFF064E3B],
        ),
      ];

  static List<TransactionModel> get initialTransactions {
    // Empty by default: no pre-registered transactions, expenses, or income
    return [];
  }

  static List<BudgetModel> get initialBudgets => [
        const BudgetModel(
          id: 'b1',
          categoryId: 'dining',
          monthlyLimit: 1000.00,
        ),
        const BudgetModel(
          id: 'b2',
          categoryId: 'shopping',
          monthlyLimit: 1500.00,
        ),
        const BudgetModel(
          id: 'b3',
          categoryId: 'travel',
          monthlyLimit: 2000.00,
        ),
        const BudgetModel(
          id: 'b4',
          categoryId: 'tech',
          monthlyLimit: 1000.00,
        ),
        const BudgetModel(
          id: 'b5',
          categoryId: 'wellness',
          monthlyLimit: 500.00,
        ),
      ];
}
