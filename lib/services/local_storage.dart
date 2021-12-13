import 'package:expense/models/categories.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

class LocalStorage implements Storage {
  late SharedPreferences _prefs;
  late List<String> _expensesStringList;
  late List<Expense> _storedExpenses;
  late Categories _categories;
  final String _expenseKey = "expense";
  final String _categoryKey = "category";

  @override
  Future<void> init({int daysToKeepRecord = -1}) async {
    _prefs = await SharedPreferences.getInstance();
    var _storedExpensesString = _prefs.getStringList(_expenseKey) ?? [];
    _storedExpenses = [];
    _expensesStringList = [];
    debugPrint("EXPENSES: ");
    for (var element in _storedExpensesString) {
      debugPrint(element);
      Expense expense = Expense.decode(element);
      if (daysToKeepRecord > -1) {
        if (expense.time.isAfter(
            DateTime.now().subtract(Duration(days: daysToKeepRecord)))) {
          _storedExpenses.add(expense);
          _expensesStringList.add(element);
        }
      } else {
        _storedExpenses.add(expense);
        _expensesStringList.add(element);
      }
    }
    if (daysToKeepRecord > -1) _saveExpenses();
    _categories =
        Categories(categories: _prefs.getStringList(_categoryKey)?.toSet());
    debugPrint(_prefs.getStringList(_categoryKey)?.toSet().toString());
  }

  void _saveExpenses() {
    _prefs.setStringList(_expenseKey, _expensesStringList);
  }

  void _saveCategories() {
    _prefs.setStringList(_categoryKey, _categories.getCategoryList());
  }

  @override
  void addExpense(Expense expense) {
    _expensesStringList.add(Expense.encode(expense));
    _storedExpenses.add(expense);
    _saveExpenses();
  }

  @override
  void removeExpense(Expense expense) {
    var index =
        _storedExpenses.indexWhere((element) => element.id == expense.id);
    _removeExpenseWithIndex(index);
  }

  void _removeExpenseWithIndex(int index) {
    if (index >= 0) {
      _storedExpenses.removeAt(index);
      _expensesStringList.removeAt(index);
      debugPrint("REMOVING EXPENSE WITH INDEX $index");
      _saveExpenses();
    }
  }

  @override
  void editExpense(Expense expense) {
    int index =
        _storedExpenses.indexWhere((element) => element.id == expense.id);
    if (index >= 0) {
      _storedExpenses[index] = expense;
      _expensesStringList[index] = Expense.encode(expense);
      _saveExpenses();
    }
  }

  @override
  void addCategory(String category) {
    _categories.addCategory(category: category);
    _saveCategories();
  }

  @override
  void removeCategory(String category) {
    _categories.removeCategory(category);
    _saveCategories();
    _removeAllExpensesForCategory(category);
  }

  void _removeAllExpensesForCategory(String category) {
    for (int i = 0; i < _storedExpenses.length; ++i) {
      if (_storedExpenses[i].category == category) {
        debugPrint(
            "REMOVING EXPENSE WITH DESCRIPTION ${_storedExpenses[i].description}");
        _removeExpenseWithIndex(i);
      }
    }
  }

  @override
  Categories getCategories() => _categories;

  @override
  List<Expense> getAllExpenses() => _storedExpenses;

  @override
  void clearStorage() {
    _prefs.remove(_expenseKey);
    _prefs.remove(_categoryKey);
  }
}
