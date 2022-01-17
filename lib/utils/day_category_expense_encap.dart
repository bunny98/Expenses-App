import 'package:expense/models/category.dart';
import 'package:expense/models/day_category_expense.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:expense/utils/date_time_extensions.dart';

class DayCategoryExpenseEncapsulator {
  late List<DayCategoryExpense> _data;
  final DateTime date;
  final ExpenseViewModel expenseViewModel;

  DayCategoryExpenseEncapsulator(
      {required this.expenseViewModel, required this.date}) {
    List<Category> _categoryList =
        expenseViewModel.getCategoryEncapsulator().getCategoryList();
    _data = [];
    for (var category in _categoryList) {
      List<Expense> expenses =
          expenseViewModel.getExpensesForCategory(category);
      List<Expense> res = [];
      int currTotal = 0;
      for (var expense in expenses) {
        if (expense.time.isSameDate(date)) {
          res.add(expense);
          currTotal += expense.amount;
        } else if (expense.time.isBeforeDate(date)) {
          break;
        }
      }
      if (res.isNotEmpty) {
        _data.add(DayCategoryExpense(
            category: Category(
                id: category.id, name: category.name, totalExpense: currTotal),
            expenses: res));
      }
    }
  }

  List<DayCategoryExpense> getData() => _data;
}
