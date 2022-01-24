import 'package:expense/models/expense.dart';

class DayExpense {
  final Expense expense;
  final bool isArchived;

  DayExpense({required this.expense, required this.isArchived});
}
