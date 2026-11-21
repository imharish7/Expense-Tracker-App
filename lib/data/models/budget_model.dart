class BudgetModel {
  final String id;
  final String categoryId;
  final double monthlyLimit;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
  });

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? monthlyLimit,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'monthlyLimit': monthlyLimit,
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}
