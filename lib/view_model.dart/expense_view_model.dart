import 'package:expense/models/category.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/services/local_storage.dart';
import 'package:expense/services/sql_storage.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';

class ExpenseViewModel with ChangeNotifier {
  late Map<Category, List<Expense>> _expenseMap;
  late Storage _storage;
  late List<PaymentMethodData> _paymentMethodCountData;
  late CategoryEncapsulator _categoryEncapsulator;
  late int _totalExpenditure;
  final int _daysToKeepRecord = 30;

  ExpenseViewModel() {
    _storage = SQLStorage();
  }

  Future<void> initViewModel() async {
    _storage.init(daysToKeepRecord: _daysToKeepRecord).then((_) async {
      await _stateInit();
    });
  }

  Future<void> _stateInit() async {
    var _expenses = await _storage.getAllExpenses();
    _categoryEncapsulator = await _storage.getCategoryEncapsulator();
    _expenseMap = {};
    for (var element in _categoryEncapsulator.getCategoryList()) {
      _expenseMap.putIfAbsent(element, () => []);
    }
    _expenseMap.forEach((key, value) {
      debugPrint(key.name + " -- " + value.length.toString());
    });
    for (var element in _expenses) {
      _expenseMap.update(
          _categoryEncapsulator.getCategoryFromId(element.categoryId), (value) {
        value.add(element);
        return value;
      });
    }
    _paymentMethodCountData = [];
    _totalExpenditure = 0;
    await calculateGraphDataAndTotalExpense();
  }

  List<Category> getAllCategories() => _categoryEncapsulator.getCategoryList();

  CategoryEncapsulator getCategoryEncapsulator() => _categoryEncapsulator;

  List<PaymentMethodData> getPaymentMethodCountData() =>
      _paymentMethodCountData;

  int getTotalExpenditure() => _totalExpenditure;

  List<Expense> getExpensesForCategory(Category category) {
    debugPrint(category.name);
    List<Expense> expenses = _expenseMap[category] ?? [];
    expenses.sort((b, a) => a.time.compareTo(b.time));
    return expenses;
  }

  Future<void> addCategory(Category category) async {
    await _storage.addCategory(category);
    _expenseMap.putIfAbsent(category, () => []);
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> removeCategory(Category category) async {
    await _storage.removeCategory(category);
    _expenseMap.remove(category);
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense, Category category) async {
    await _storage.addExpense(expense, category);
    _expenseMap[category]!.add(expense);
    _expenseMap.forEach((key, value) {
      debugPrint(key.name + " -- " + value.length.toString());
    });
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> removeExpense(Expense expense, Category category) async {
    await _storage.removeExpense(expense, category);
    _expenseMap[_categoryEncapsulator.getCategoryFromId(expense.categoryId)]!
        .removeWhere((element) => element.id == expense.id);
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory}) async {
    await _storage.editExpense(
        oldExpense: oldExpense,
        newExpense: newExpense,
        oldCategory: oldCategory,
        newCategory: newCategory);
    _expenseMap[oldCategory]!.removeWhere((e) => e.id == oldExpense.id);
    _expenseMap[newCategory]!.add(newExpense);
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> clearStorage() async {
    await _storage.clearStorage();
    await _stateInit();
    notifyListeners();
  }

  Future<void> calculateGraphDataAndTotalExpense() async {
    _categoryEncapsulator = await _storage.getCategoryEncapsulator();
    //GRAPH 2
    Map<String, int> mp = {};
    for (var ele in (await _storage.getAllExpenses())) {
      mp.update(
        ele.paymentType,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    List<PaymentMethodData> res1 = mp.entries
        .map((entry) => PaymentMethodData(entry.value, entry.key))
        .toList();
    _paymentMethodCountData = res1;

    calculateTotalExpenditure();
  }

  void calculateTotalExpenditure() {
    int res = 0;
    for (var element in _categoryEncapsulator.getCategoryList()) {
      res += element.totalExpense;
    }
    _totalExpenditure = res;
  }

  Future<void> importData(BuildContext context) async {
    await _storage.importData(context: context);
    await _stateInit();
    notifyListeners();
  }

  Future<void> exportData(BuildContext context) async {
    await _storage.exportData(context: context);
  }
}
