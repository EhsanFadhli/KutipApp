
import 'dart:convert';

class Payment {
  final String name;
  final String block;
  final String unit;
  final String phone;
  final String fromMonth;
  final int fromYear;
  final String untilMonth;
  final int untilYear;
  final double amountToPay;
  final double amountReceived;
  final double balance;
  final DateTime createdAt;

  Payment({
    required this.name,
    required this.block,
    required this.unit,
    required this.phone,
    required this.fromMonth,
    required this.fromYear,
    required this.untilMonth,
    required this.untilYear,
    required this.amountToPay,
    required this.amountReceived,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'block': block,
      'unit': unit,
      'phone': phone,
      'fromMonth': fromMonth,
      'fromYear': fromYear,
      'untilMonth': untilMonth,
      'untilYear': untilYear,
      'amountToPay': amountToPay,
      'amountReceived': amountReceived,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      name: map['name'] ?? '',
      block: map['block'] ?? '',
      unit: map['unit'] ?? '',
      phone: map['phone'] ?? '',
      fromMonth: map['fromMonth'] ?? '',
      fromYear: map['fromYear']?.toInt() ?? 0,
      untilMonth: map['untilMonth'] ?? '',
      untilYear: map['untilYear']?.toInt() ?? 0,
      amountToPay: map['amountToPay']?.toDouble() ?? 0.0,
      amountReceived: map['amountReceived']?.toDouble() ?? 0.0,
      balance: map['balance']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) => Payment.fromMap(json.decode(source));
}
