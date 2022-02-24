import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/metadata.dart';
import 'package:expense/models/metadata_types.dart';
import 'package:expense/models/time_indexed_expense.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/services/sql_storage.dart';
import 'package:expense/services/storage.dart';
import 'package:expense/utils/date_time_extensions.dart';
import 'package:flutter/material.dart';

class ExpenseViewModel with ChangeNotifier {
  late Map<Category, List<Expense>> _expenseMap;
  late Storage _storage;
  // late UpiService _upiService;
  late List<PaymentMethodData> _paymentMethodCountData;
  late CategoryEncapsulator _categoryEncapsulator;
  late ArchiveParams? _archiveParams;
  late int _totalExpenditure;
  final int _daysToKeepRecord = 30;

  ExpenseViewModel() {
    _storage = SQLStorage();
    // _upiService = UpiService();
  }

  Future<void> initViewModel() async {
    _storage.init(daysToKeepRecord: _daysToKeepRecord).then((_) async {
      await _initArchiveState();
      await _appStateInit();
      // await _upiService.init();
    });
  }

  Future<void> _initArchiveState() async {
    _archiveParams = _storage.getArchiveParams();
    if (_archiveParams != null) {
      debugPrint(
          "ARCHIVE PARAMS : ${_archiveParams!.archiveOnEvery} ${_archiveParams!.nextArchiveOn.toString()}  ${_archiveParams!.prevArchiveOn.toString()}");
      if (_archiveParams!.nextArchiveOn.isSameDate(DateTime.now()) ||
          _archiveParams!.nextArchiveOn.isBefore(DateTime.now())) {
        await archiveAllExpenses();
      }
    }
  }

  Future<void> _appStateInit() async {
    var _expenses = await _storage.getAllExpenses();
    _categoryEncapsulator = await _storage.getCategoryEncapsulator();
    _expenseMap = {};
    for (var element in _categoryEncapsulator.getCategoryList()) {
      _expenseMap.putIfAbsent(element, () => []);
    }
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

  // UpiAppsEncapsulator getUpiAppEncapsulator() =>
  //     _upiService.getUpiAppEncapsulator();

  List<PaymentMethodData> getPaymentMethodCountData() =>
      _paymentMethodCountData;

  int getTotalExpenditure() => _totalExpenditure;

  ArchiveParams? getArchiveParams() => _archiveParams;

  List<Expense> getExpensesForCategory(Category category) {
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

  Future<void> addExpense(Expense expense) async {
    Category category =
        _categoryEncapsulator.getCategoryFromId(expense.categoryId);
    await _storage.addExpense(expense, category);
    _expenseMap[category]!.add(expense);
    await calculateGraphDataAndTotalExpense();
    notifyListeners();
  }

  Future<void> removeExpense(Expense expense) async {
    await _storage.removeExpense(
        expense, _categoryEncapsulator.getCategoryFromId(expense.categoryId));
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
    await _appStateInit();
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
    await _appStateInit();
    notifyListeners();
  }

  Future<void> exportData(BuildContext context) async {
    await _storage.exportData(context: context);
  }

  List<TimeIndexedCategoryExpense> getAllTimeIndexedCategoryExpense(
      Category category, List<Expense> expenses) {
    List<TimeIndexedCategoryExpense> res = [];
    if (expenses.isNotEmpty) {
      DateTime currTime = expenses[0].time;
      List<Expense> currTimeExpenses = [expenses[0]];
      int currTotal = expenses[0].amount;
      for (int i = 1; i < expenses.length; ++i) {
        if (expenses[i].time.day == currTime.day) {
          currTimeExpenses.add(expenses[i]);
          currTotal += expenses[i].amount;
        } else {
          res.add(TimeIndexedCategoryExpense(
              total: currTotal, time: currTime, expenses: currTimeExpenses));
          currTime = expenses[i].time;
          currTimeExpenses = [expenses[i]];
          currTotal = expenses[i].amount;
        }
      }
      res.add(TimeIndexedCategoryExpense(
          total: currTotal, time: currTime, expenses: currTimeExpenses));
    }
    return res;
  }

  // Future<Category?> getCategoryForUpiId(String upiId) async {
  //   UPICategory? upiCategory = await _storage.getUpiCategory(upiId: upiId);
  //   return upiCategory != null
  //       ? _categoryEncapsulator.getCategoryFromId(upiCategory.categoryId)
  //       : null;
  // }

  // Future<void> addUpiCategory(UPICategory upiCategory) async {
  //   await _storage.addUpiCategory(upiCategory);
  // }

  // Future<void> updateUpiCategory(UPICategory upiCategory) async {
  //   await _storage.updateUpiCategory(upiCategory);
  // }

  // Future<TransactionStatus> initiateUpiTransaction(
  //     {required UPIPayment upiPayment, required String expenseId}) async {
  //   return await _upiService.initiateTransaction(
  //       upiPayment: upiPayment, expenseId: expenseId);
  // }

  Future<void> scheduleArchive({required ArchiveParams archiveParams}) async {
    _archiveParams = archiveParams;
    await _storage.saveArchiveParams(archiveParams: archiveParams);
  }

  // Future<void> archiveExpense({required Expense expense}) async {
  //   await _storage.archiveExpense(expense: expense);
  //   await removeExpense(expense);
  // }

  // Future<void> unArchiveExpense({required Expense expense}) async {
  //   await addExpense(expense);
  //   await _storage.unArchiveExpense(
  //     expense: expense,
  //   );
  // }

  Future<void> archiveAllExpenses({bool shouldInitAppState = false}) async {
    await _saveMetadata();
    await _storage.archiveAllExpenses();
    ArchiveParams temp = ArchiveParams.fromArchiveOnEvery(
        archiveOnEvery: _archiveParams!.archiveOnEvery,
        previouslyAchivedOn: DateTime.now());
    await _storage.saveArchiveParams(archiveParams: temp);
    _archiveParams = temp;
    if (shouldInitAppState) {
      await _appStateInit();
      notifyListeners();
    }
  }

  Future<List<Expense>> getAllArchivedExpensesForCategory(
      {required Category category}) async {
    List<Expense> expenses =
        await _storage.getAllArchivedExpensesOfCategory(category: category);
    expenses.sort((b, a) => a.time.compareTo(b.time));
    return expenses;
  }

  Future<List<Expense>> getAllArchivedExpensesOfDate(
      {required DateTime dateTime}) async {
    List<Expense> expenses =
        await _storage.getAllArchivedExpensesOnDate(datetime: dateTime);
    return expenses;
  }

  Future<List<Expense>> getAllExpensesOfDate(
      {required DateTime dateTime}) async {
    List<Expense> expenses =
        await _storage.getAllExpensesOnDate(datetime: dateTime);
    return expenses;
  }

  Future<void> _saveMetadata() async => await _storage.saveMetadata(
      metadataList: _categoryEncapsulator.getCurrentMonthMetadata());
}
