import 'package:expense/models/category.dart';
import 'package:expense/models/category_encap.dart';
import 'package:expense/models/expense.dart';

abstract class Storage {
  Future<void> init({int daysToKeepRecord = -1});
  Future<void> clearStorage();
  Future<void> addExpense(Expense expense, Category category);
  Future<void> removeExpense(Expense expense, Category category);
  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory});
  Future<void> addCategory(Category category);
  Future<void> removeCategory(Category category);
  Future<List<Expense>> getAllExpenses();
  Future<CategoryEncapsulator> getCategoryEncapsulator();
}
