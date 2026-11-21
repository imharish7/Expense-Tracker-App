import 'package:flutter/material.dart';

enum CategoryType { expense, income }

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  static const List<CategoryItem> defaultCategories = [
    // Expenses
    CategoryItem(
      id: 'dining',
      name: 'Dining & Cocktails',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF59E0B),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Luxury Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'housing',
      name: 'Housing & Estate',
      icon: Icons.villa_rounded,
      color: Color(0xFF3B82F6),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'travel',
      name: 'Travel & First Class',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF06B6D4),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'tech',
      name: 'Tech & Gadgets',
      icon: Icons.devices_other_rounded,
      color: Color(0xFF8B5CF6),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'automotive',
      name: 'Automotive & Fuel',
      icon: Icons.directions_car_filled_rounded,
      color: Color(0xFFEF4444),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'wellness',
      name: 'Health & Spa',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment & Clubs',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFFA855F7),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: 'services',
      name: 'Bills & Concierge',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF64748B),
      type: CategoryType.expense,
    ),

    // Incomes
    CategoryItem(
      id: 'salary',
      name: 'Executive Retainer',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
      type: CategoryType.income,
    ),
    CategoryItem(
      id: 'investments',
      name: 'Capital Gains & Dividends',
      icon: Icons.trending_up_rounded,
      color: Color(0xFFE5B869),
      type: CategoryType.income,
    ),
    CategoryItem(
      id: 'freelance',
      name: 'Consulting & Advising',
      icon: Icons.military_tech_rounded,
      color: Color(0xFF06B6D4),
      type: CategoryType.income,
    ),
    CategoryItem(
      id: 'crypto',
      name: 'Crypto Yield & Staking',
      icon: Icons.currency_bitcoin_rounded,
      color: Color(0xFFF97316),
      type: CategoryType.income,
    ),
    CategoryItem(
      id: 'other_income',
      name: 'Other Inflows',
      icon: Icons.savings_rounded,
      color: Color(0xFF8B5CF6),
      type: CategoryType.income,
    ),
  ];

  static CategoryItem findById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const CategoryItem(
        id: 'misc',
        name: 'General / Other',
        icon: Icons.category_rounded,
        color: Color(0xFF94A3B8),
        type: CategoryType.expense,
      ),
    );
  }
}
