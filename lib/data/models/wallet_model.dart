import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String name;
  final String type; // 'credit', 'checking', 'savings', 'crypto', 'cash'
  final double balance;
  final String cardNumber; // e.g. "•••• 8824"
  final List<int> gradientHexes;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.cardNumber,
    required this.gradientHexes,
  });

  List<Color> get gradientColors =>
      gradientHexes.map((hex) => Color(hex)).toList();

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? cardNumber,
    List<int>? gradientHexes,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      cardNumber: cardNumber ?? this.cardNumber,
      gradientHexes: gradientHexes ?? this.gradientHexes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'cardNumber': cardNumber,
      'gradientHexes': gradientHexes,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'checking',
      balance: (json['balance'] as num).toDouble(),
      cardNumber: json['cardNumber'] as String? ?? '•••• 0000',
      gradientHexes: (json['gradientHexes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0xFF1E2433, 0xFF11141C],
    );
  }
}
