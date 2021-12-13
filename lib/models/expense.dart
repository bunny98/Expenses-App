import 'dart:convert';

class Expense {
  final String id;
  final int amount;
  final String description;
  final String paymentType;
  final DateTime time;
  final String category;

  Expense(
      {required this.id,
      required this.amount,
      required this.description,
      required this.paymentType,
      required this.time,
      required this.category});

  factory Expense.fromJson(Map<String, dynamic> jsonData) {
    return Expense(
      id: jsonData['id'],
      amount: jsonData['amount'],
      description: jsonData['description'],
      paymentType: jsonData['paymentType'],
      time: DateTime.parse(jsonData['time']),
      category: jsonData['category'],
    );
  }

  static Map<String, dynamic> toMap(Expense expense) => {
        'id': expense.id,
        'amount': expense.amount,
        'description': expense.description,
        'paymentType': expense.paymentType,
        'time': expense.time.toString(),
        'category': expense.category,
      };

  static String encode(Expense expense) => json.encode(Expense.toMap(expense));
  static Expense decode(String expense) =>
      Expense.fromJson(json.decode(expense));
}
