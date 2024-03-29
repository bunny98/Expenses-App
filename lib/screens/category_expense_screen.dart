import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/time_indexed_expense.dart';
import 'package:expense/utils/add_expense_screen_enum.dart';
import 'package:expense/utils/popup_menu_item_encap.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'add_edit_expense_screen.dart';

class CategoryExpenseScreen extends StatefulWidget {
  const CategoryExpenseScreen({Key? key, required this.category})
      : super(key: key);
  final Category category;

  @override
  _CategoryExpenseScreenState createState() => _CategoryExpenseScreenState();
}

class _CategoryExpenseScreenState extends State<CategoryExpenseScreen> {
  CategoryExpenseState _categoryExpenseState = CategoryExpenseState.UNARCHIVED;
  late PoppupMenuEncapsulator<String> _poppupMenuEncapsulator;

  @override
  void initState() {
    super.initState();
    _poppupMenuEncapsulator = PoppupMenuEncapsulator<String>();
    _poppupMenuEncapsulator.addItem(
        key: "Show Archived",
        onClick: () {
          setState(() {
            _categoryExpenseState = CategoryExpenseState.ARCHIVED;
          });
        });
    _poppupMenuEncapsulator.addItem(
        key: "Show Unarchived",
        onClick: () {
          setState(() {
            _categoryExpenseState = CategoryExpenseState.UNARCHIVED;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryExpenseState == CategoryExpenseState.ARCHIVED
            ? "Archived ${widget.category.name}"
            : "${widget.category.name} Expenses"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _poppupMenuEncapsulator.getOnclickFunction(),
            itemBuilder: (BuildContext context) =>
                _poppupMenuEncapsulator.getItems(),
          ),
        ],
      ),
      body: CategoryExpenseList(
        category: widget.category,
        categoryExpenseState: _categoryExpenseState,
      ),
    );
  }
}

class CategoryExpenseList extends StatefulWidget {
  const CategoryExpenseList(
      {Key? key, required this.categoryExpenseState, required this.category})
      : super(key: key);
  final CategoryExpenseState categoryExpenseState;
  final Category category;

  @override
  _CategoryExpenseListState createState() => _CategoryExpenseListState();
}

class _CategoryExpenseListState extends State<CategoryExpenseList> {
  late ExpenseViewModel _expenseViewModel;

  @override
  void initState() {
    super.initState();
    _expenseViewModel = context.read<ExpenseViewModel>();
  }

  Future<List<TimeIndexedCategoryExpense>> getInitFuture() async {
    switch (widget.categoryExpenseState) {
      case CategoryExpenseState.ARCHIVED:
        return _expenseViewModel.getAllTimeIndexedCategoryExpense(
            widget.category,
            await _expenseViewModel.getAllArchivedExpensesForCategory(
                category: widget.category));
      default:
        return _expenseViewModel.getAllTimeIndexedCategoryExpense(
            widget.category,
            _expenseViewModel.getExpensesForCategory(widget.category));
    }
  }

  ActionPane _getActionPane(Expense expense) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        // A SlidableAction can have an icon and/or a label.
        SlidableAction(
          onPressed: (_) async {
            if (widget.categoryExpenseState ==
                CategoryExpenseState.UNARCHIVED) {
              await context
                  .read<ExpenseViewModel>()
                  .archiveExpense(expense: expense);
            } else {
              await context
                  .read<ExpenseViewModel>()
                  .unArchiveExpense(expense: expense);
            }
          },
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: widget.categoryExpenseState == CategoryExpenseState.UNARCHIVED
              ? Icons.archive
              : Icons.unarchive,
        ),
        if (widget.categoryExpenseState == CategoryExpenseState.UNARCHIVED)
          SlidableAction(
            onPressed: (_) {
              context.read<ExpenseViewModel>().removeExpense(expense);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        if (widget.categoryExpenseState == CategoryExpenseState.UNARCHIVED)
          SlidableAction(
            onPressed: (_) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEditExpenseScreen(
                          expense: expense,
                          mode: AddExpenseMode.EDIT,
                        ))),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: Icons.edit,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(builder: (context, model, _) {
      return FutureBuilder(
          future: getInitFuture(),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<TimeIndexedCategoryExpense> _timeIndexedExpenses =
                snap.data as List<TimeIndexedCategoryExpense>;
            return _timeIndexedExpenses.isEmpty &&
                    widget.categoryExpenseState ==
                        CategoryExpenseState.UNARCHIVED
                ? Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Add Expenses",
                            style: TextStyle(color: Colors.grey),
                          ),
                          AddExpenseFromCategoryScreenButton(
                              category: widget.category),
                        ]),
                  )
                : _timeIndexedExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          "No Archived Expenses",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Swipe tile for options...",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    if (widget.categoryExpenseState ==
                                        CategoryExpenseState.UNARCHIVED)
                                      AddExpenseFromCategoryScreenButton(
                                          category: widget.category),
                                  ]),
                            );
                          }
                          List<Expense> _expenses =
                              _timeIndexedExpenses[index - 1].expenses;
                          return ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy').format(
                                              _timeIndexedExpenses[index - 1]
                                                  .time),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          "\u{20B9}${_timeIndexedExpenses[index - 1].total}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                for (int i = 0; i < _expenses.length; ++i)
                                  Slidable(
                                    key: ValueKey(_expenses[i].id),
                                    startActionPane:
                                        _getActionPane(_expenses[i]),
                                    endActionPane: _getActionPane(_expenses[i]),
                                    closeOnScroll: true,
                                    child: ListTile(
                                      subtitle: Text(DateFormat('hh:mm a')
                                          .format(_expenses[i].time)),
                                      leading: Text(
                                          "\u{20B9}${_expenses[i].amount}"),
                                      title: Text(_expenses[i].description),
                                      trailing: Text(_expenses[i].paymentType),
                                    ),
                                  ),
                              ]);
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: _timeIndexedExpenses.length + 1);
          });
    });
  }
}

class AddExpenseFromCategoryScreenButton extends StatelessWidget {
  const AddExpenseFromCategoryScreenButton({
    Key? key,
    required this.category,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => AddEditExpenseScreen(
                  category: category,
                  mode: AddExpenseMode.ADDITION_FROM_CATEGORY_PAGE,
                ))),
        icon: const Icon(Icons.add, color: Colors.black));
  }
}

enum CategoryExpenseState { ARCHIVED, UNARCHIVED }
