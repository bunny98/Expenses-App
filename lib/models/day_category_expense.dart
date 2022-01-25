import 'package:expense/models/category.dart';
import 'package:expense/models/day_expense.dart';
import 'package:expense/models/expense.dart';

class DayCategoryExpense {
  final Category category;
  final List<DayExpense> dayExpenses;

  DayCategoryExpense({required this.category, required this.dayExpenses});
}
