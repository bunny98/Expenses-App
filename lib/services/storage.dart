import 'package:expense/models/categories.dart';
import 'package:expense/models/expense.dart';

abstract class Storage {
  Future<void> init({int daysToKeepRecord = -1});
  void clearStorage();
  void addExpense(Expense expense);
  void removeExpense(Expense expense);
  void editExpense(Expense expense);
  void addCategory(String category);
  void removeCategory(String category);
  List<Expense> getAllExpenses();
  Categories getCategories();
}
