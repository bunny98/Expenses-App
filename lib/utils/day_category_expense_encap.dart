import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/day_category_expense.dart';
import 'package:expense/models/day_expense.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:expense/utils/date_time_extensions.dart';

class DayCategoryExpenseEncapsulator {
  late List<DayCategoryExpense> _data;
  final DateTime date;
  final ExpenseViewModel expenseViewModel;
  late bool _shouldOnlyFetchFromExpensesTable;

  DayCategoryExpenseEncapsulator(
      {required this.expenseViewModel, required this.date}) {
    ArchiveParams? _archiveParams = expenseViewModel.getArchiveParams();
    if (_archiveParams != null &&
        _archiveParams.prevArchiveOn != null &&
        !_archiveParams.prevArchiveOn!.isBeforeDate(date)) {
      //ALSO FETCH FROM ARCHIVE TABLE
      _shouldOnlyFetchFromExpensesTable = false;
    } else {
      //FETCH ONLY FROM EXPENSES TABLE
      _shouldOnlyFetchFromExpensesTable = true;
    }
  }

  Future<List<DayCategoryExpense>> getData() async {
    _data = [];
    List<Category> _categoryList =
        expenseViewModel.getCategoryEncapsulator().getCategoryList();
    List<DayExpense> dayExpenses = await _getDayExpenses();
    Map<String, List<DayExpense>> _catExpMap = {};
    Map<String, int> _catTotalMap = {};
    for (var category in _categoryList) {
      _catExpMap.putIfAbsent(category.id, () => []);
      _catTotalMap.putIfAbsent(category.id, () => 0);
    }
    for (var dayExp in dayExpenses) {
      if (_catExpMap.containsKey(dayExp.expense.categoryId) &&
          _catTotalMap.containsKey(dayExp.expense.categoryId)) {
        _catExpMap[dayExp.expense.categoryId]!.add(dayExp);
        int currSum = _catTotalMap[dayExp.expense.categoryId]!;
        currSum += dayExp.expense.amount;
        _catTotalMap[dayExp.expense.categoryId] = currSum;
      }
    }
    for (var category in _categoryList) {
      if (_catExpMap.containsKey(category.id) &&
          _catExpMap[category.id]!.isNotEmpty) {
        _data.add(DayCategoryExpense(
            category: Category(
                id: category.id,
                name: category.name,
                totalExpense: _catTotalMap[category.id] ?? 0),
            dayExpenses: _catExpMap[category.id]!));
      }
    }
    return _data;
  }

  Future<List<DayExpense>> _getDayExpenses() async {
    var unarchivedExp =
        await expenseViewModel.getAllExpensesOfDate(dateTime: date);
    List<DayExpense> res = [];
    for (var element in unarchivedExp) {
      res.add(DayExpense(expense: element, isArchived: false));
    }
    if (!_shouldOnlyFetchFromExpensesTable) {
      var archivedExp =
          await expenseViewModel.getAllArchivedExpensesOfDate(dateTime: date);
      for (var element in archivedExp) {
        res.add(DayExpense(expense: element, isArchived: true));
      }
    }
    res.sort((b, a) => a.expense.time.compareTo(b.expense.time));
    return res;
  }
}
