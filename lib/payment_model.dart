
import 'dart:convert';

class Payment {
  String name;
  String phone;
  String block;
  String unit;
  double amountToPay;
  double amountReceived;
  double balance;
  DateTime createdAt;
  String fromMonth;
  String untilMonth;
  String fromYear;
  String untilYear;

  Payment({
    required this.name,
    required this.phone,
    required this.block,
    required this.unit,
    required this.amountToPay,
    required this.amountReceived,
    required this.balance,
    required this.createdAt,
    required this.fromMonth,
    required this.untilMonth,
    required this.fromYear,
    required this.untilYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'block': block,
      'unit': unit,
      'amountToPay': amountToPay,
      'amountReceived': amountReceived,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'fromMonth': fromMonth,
      'untilMonth': untilMonth,
      'fromYear': fromYear,
      'untilYear': untilYear,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      block: map['block'] ?? '',
      unit: map['unit'] ?? '',
      amountToPay: (map['amountToPay'] as num?)?.toDouble() ?? 0.0,
      amountReceived: (map['amountReceived'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      fromMonth: map['fromMonth'] ?? '',
      untilMonth: map['untilMonth'] ?? '',
      fromYear: map['fromYear'] ?? '',
      untilYear: map['untilYear'] ?? '',
    );
  }

    String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) => Payment.fromMap(json.decode(source));

}
