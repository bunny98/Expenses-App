import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';
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
  ActionPane _getActionPane(Expense expense) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        // A SlidableAction can have an icon and/or a label.
        SlidableAction(
          onPressed: (_) {
            var _categoryEncap =
                context.read<ExpenseViewModel>().getCategoryEncapsulator();
            context.read<ExpenseViewModel>().removeExpense(
                expense, _categoryEncap.getCategoryFromId(expense.categoryId));
            setState(() {});
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
        SlidableAction(
          onPressed: (_) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEditExpenseScreen(
                        expense: expense,
                      ))),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: Icons.edit,
          label: 'Edit',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category.name} Expenses"),
      ),
      body: Consumer<ExpenseViewModel>(builder: (context, model, _) {
        List<Expense> _expenses = model.getExpensesForCategory(widget.category);
        return _expenses.isEmpty
            ? const Center(
                child: Text("No expenses"),
              )
            : ListView.separated(
                itemBuilder: (context, index) => index == 0
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Slide for options...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Slidable(
                        key: ValueKey(_expenses[index - 1].id),
                        startActionPane: _getActionPane(_expenses[index - 1]),
                        endActionPane: _getActionPane(_expenses[index - 1]),
                        closeOnScroll: true,
                        child: ListTile(
                          subtitle: Text(DateFormat('dd/MM/yyyy  kk:mm')
                              .format(_expenses[index - 1].time)),
                          leading:
                              Text("\u{20B9}${_expenses[index - 1].amount}"),
                          title: Text(_expenses[index - 1].description),
                          trailing: Text(_expenses[index - 1].paymentType),
                        ),
                      ),
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _expenses.length + 1);
      }),
    );
  }
}
