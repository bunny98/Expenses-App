import 'package:expense/models/month_to_expense.dart';

class MonthlyCatExpense {
  final String categoryName;
  final String categoryId;
  late List<MonthToExpense> _data;

  MonthlyCatExpense({
    required this.categoryName,
    required this.categoryId,
  }) {
    _data = [];
  }

  void addExpenseAmount(String month, int amt) =>
      _data.add(MonthToExpense(month, amt));

  List<MonthToExpense> getData() => _data;
}
