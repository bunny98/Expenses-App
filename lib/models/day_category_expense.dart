import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';

class DayCategoryExpense {
  final Category category;
  final List<Expense> expenses;

  DayCategoryExpense({required this.category, required this.expenses});
}
