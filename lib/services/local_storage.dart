import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/upi_category.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:uuid/uuid.dart';

class LocalStorage implements Storage {
  late SharedPreferences _prefs;
  late List<String> _expensesStringList;
  late List<Expense> _storedExpenses;
  late CategoryEncapsulator _categories;
  final String _expenseKey = "expense";
  final String _categoryKey = "category";
  final _uuid = Uuid();

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
    var _categoryStringSet = _prefs.getStringList(_categoryKey)?.toSet();
    if (_categoryStringSet != null) {
      Set<Category> _categorySet =
          Set.from(_categoryStringSet.map((ele) => Category.decode(ele)));
      _categories = CategoryEncapsulator(
          categories: _categorySet, defaultCategory: _categorySet.first);
    } else {
      _categories = CategoryEncapsulator.defaultValue();
      _saveCategories();
    }
  }

  void _saveExpenses() {
    _prefs.setStringList(_expenseKey, _expensesStringList);
  }

  void _saveCategories() {
    _prefs.setStringList(_categoryKey,
        _categories.getCategoryList().map((e) => Category.encode(e)).toList());
  }

  @override
  Future<void> addExpense(Expense expense, Category category) async {
    _expensesStringList.add(Expense.encode(expense));
    _storedExpenses.add(expense);
    _categories.overrideCategory(Category(
        id: category.id,
        name: category.name,
        totalExpense: category.totalExpense + expense.amount));
    _saveCategories();
    _saveExpenses();
  }

  @override
  Future<void> removeExpense(Expense expense, Category category) async {
    var index =
        _storedExpenses.indexWhere((element) => element.id == expense.id);
    _removeExpenseWithIndex(index);
    _categories.overrideCategory(Category(
        id: category.id,
        name: category.name,
        totalExpense: category.totalExpense - expense.amount));
    _saveCategories();
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
  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory}) async {
    int index =
        _storedExpenses.indexWhere((element) => element.id == oldExpense.id);
    if (index >= 0) {
      _storedExpenses[index] = newExpense;
      _expensesStringList[index] = Expense.encode(newExpense);
      _saveExpenses();
    }
    _categories.overrideCategory(Category(
        id: oldCategory.id,
        name: oldCategory.name,
        totalExpense: oldCategory.totalExpense - oldExpense.amount));
    _categories.overrideCategory(Category(
        id: newCategory.id,
        name: newCategory.name,
        totalExpense: newCategory.totalExpense + newExpense.amount));
    _saveCategories();
  }

  @override
  Future<void> addCategory(Category category) async {
    _categories.addCategory(category: category);
    _saveCategories();
  }

  @override
  Future<void> removeCategory(Category category) async {
    _categories.removeCategory(category);
    _saveCategories();
    _removeAllExpensesForCategory(category.id);
  }

  void _removeAllExpensesForCategory(String categoryId) {
    for (int i = 0; i < _storedExpenses.length; ++i) {
      if (_storedExpenses[i].categoryId == categoryId) {
        debugPrint(
            "REMOVING EXPENSE WITH DESCRIPTION ${_storedExpenses[i].description}");
        _removeExpenseWithIndex(i);
      }
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async => _storedExpenses;

  @override
  Future<void> clearStorage() async {
    _prefs.remove(_expenseKey);
    _prefs.remove(_categoryKey);
  }

  @override
  Future<CategoryEncapsulator> getCategoryEncapsulator() async => _categories;

  @override
  Future<void> exportData({required BuildContext context}) {
    // TODO: implement exportData
    throw UnimplementedError();
  }

  @override
  Future<void> importData({required BuildContext context}) {
    // TODO: implement importData
    throw UnimplementedError();
  }

  @override
  Future<void> addUpiCategory(UPICategory upiCategory) {
    // TODO: implement addUpiCategory
    throw UnimplementedError();
  }

  @override
  Future<void> updateUpiCategory(UPICategory upiCategory) {
    // TODO: implement updateUpiCategory
    throw UnimplementedError();
  }

  @override
  Future<UPICategory> getUpiCategory({required String upiId}) {
    // TODO: implement getUpiCategory
    throw UnimplementedError();
  }

  @override
  Future<void> archiveAllExpenses() {
    // TODO: implement archiveAllExpenses
    throw UnimplementedError();
  }

  @override
  Future<void> archiveExpense({required Expense expense}) {
    // TODO: implement archiveExpense
    throw UnimplementedError();
  }

  @override
  Future<List<Expense>> getAllArchivedExpensesOfCategory(
      {required Category category}) {
    // TODO: implement getAllArchivedExpenses
    throw UnimplementedError();
  }

  @override
  Future<void> unArchiveExpense(
      {required Expense expense, required Category category}) {
    // TODO: implement unArchiveExpense
    throw UnimplementedError();
  }

  @override
  Future<void> saveArchiveParams({required ArchiveParams archiveParams}) {
    // TODO: implement saveArchiveParams
    throw UnimplementedError();
  }

  @override
  ArchiveParams? getArchiveParams() {
    // TODO: implement getArchiveParams
    throw UnimplementedError();
  }

  @override
  Future<List<Expense>> getAllArchivedExpensesOnDate(
      {required DateTime datetime}) {
    // TODO: implement getAllArchivedExpensesOnDate
    throw UnimplementedError();
  }

  @override
  Future<List<Expense>> getAllExpensesOnDate({required DateTime datetime}) {
    // TODO: implement getAllExpensesOnDate
    throw UnimplementedError();
  }
}
