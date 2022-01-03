import 'expense.dart';

class TimeIndexedCategoryExpense {
  final DateTime time;
  final List<Expense> expenses;
  final int total;

  TimeIndexedCategoryExpense(
      {required this.total, required this.time, required this.expenses});
}
