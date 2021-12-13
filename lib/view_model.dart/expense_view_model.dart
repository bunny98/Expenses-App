import 'package:expense/models/categories.dart';
import 'package:expense/models/category_expense_data.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/services/local_storage.dart';
import 'package:expense/services/storage.dart';
import 'package:flutter/material.dart';

class ExpenseViewModel with ChangeNotifier {
  late Map<String, List<Expense>> _expenseMap;
  late Storage _storage;
  late List<CategoryExpenseData> _categoryExpenseData;
  late List<PaymentMethodData> _paymentMethodCountData;
  late int _totalExpenditure;
  final int _daysToKeepRecord = 30;

  ExpenseViewModel() {
    _storage = LocalStorage();
  }

  Future<void> initViewModel() async {
    _storage.init(daysToKeepRecord: _daysToKeepRecord).then((_) {
      var _expenses = _storage.getAllExpenses();
      var _categories = _storage.getCategories().getCategoryList();
      _expenseMap = {};
      for (var element in _categories) {
        _expenseMap.putIfAbsent(element, () => []);
      }
      for (var element in _expenses) {
        _expenseMap.update(element.category, (value) {
          value.add(element);
          return value;
        });
      }
      _categoryExpenseData = [];
      _paymentMethodCountData = [];
      _totalExpenditure = 0;
      calculateGraphDataAndTotalExpense();
    });
  }

  List<String> getAllCategories() => _storage.getCategories().getCategoryList();

  Categories getCategories() => _storage.getCategories();

  List<CategoryExpenseData> getCategoryExpenseData() => _categoryExpenseData;

  List<PaymentMethodData> getPaymentMethodCountData() =>
      _paymentMethodCountData;

  int getTotalExpenditure() => _totalExpenditure;

  List<Expense>? getExpensesForCategory(String category) {
    List<Expense> expenses = _expenseMap[category] ?? [];
    expenses.sort((a, b) => a.time.compareTo(b.time));
    return expenses;
  }

  int getTotalExpenseOfCategory(String category) {
    int res = 0;
    var _expenses = _expenseMap[category];
    for (var element in _expenses!) {
      res += element.amount;
    }
    return res;
  }

  Future<void> addCategory(String category) async {
    _storage.addCategory(category);
    _expenseMap.putIfAbsent(category, () => []);
    calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> removeCategory(String category) async {
    _storage.removeCategory(category);
    _expenseMap.remove(category);
    calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _storage.addExpense(expense);
    _expenseMap[expense.category]!.add(expense);
    calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  void removeExpense(Expense expense) {
    _storage.removeExpense(expense);
    _expenseMap[expense.category]!
        .removeWhere((element) => element.id == expense.id);
    calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> editExpense(Expense expense) async {
    _storage.editExpense(expense);
    await initViewModel();
    notifyListeners();
  }

  void clearStorage() {
    _storage.clearStorage();
    initViewModel();
    notifyListeners();
  }

  void calculateGraphDataAndTotalExpense() {
    //GRAPH 1
    List<CategoryExpenseData> res = [];
    _storage.getCategories().getCategoryList().forEach((cat) {
      res.add(CategoryExpenseData(getTotalExpenseOfCategory(cat), cat));
    });
    _categoryExpenseData = res;

    //GRAPH 2
    Map<String, int> mp = {};
    _storage.getAllExpenses().forEach((ele) {
      mp.update(
        ele.paymentType,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    });
    List<PaymentMethodData> res1 = mp.entries
        .map((entry) => PaymentMethodData(entry.value, entry.key))
        .toList();
    _paymentMethodCountData = res1;

    calculateTotalExpenditure();
  }

  void calculateTotalExpenditure() {
    int res = 0;
    for (var element in _categoryExpenseData) {
      res += element.expense;
    }
    _totalExpenditure = res;
  }
}
