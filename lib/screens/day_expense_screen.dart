import 'package:date_time_picker/date_time_picker.dart';
import 'package:expense/models/day_category_expense.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/utils/add_expense_screen_enum.dart';
import 'package:expense/utils/day_category_expense_encap.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';

import 'add_edit_expense_screen.dart';

class DayExpenseScreen extends StatefulWidget {
  DayExpenseScreen({Key? key}) : super(key: key);

  @override
  _DayExpenseScreenState createState() => _DayExpenseScreenState();
}

class _DayExpenseScreenState extends State<DayExpenseScreen> {
  late ExpenseViewModel _expenseViewModel;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _expenseViewModel = context.read<ExpenseViewModel>();
    _date = DateTime.now();
  }

  List<DayCategoryExpense> getData() {
    DayCategoryExpenseEncapsulator _encap = DayCategoryExpenseEncapsulator(
        expenseViewModel: _expenseViewModel, date: _date);
    return _encap.getData();
  }

  ActionPane _getActionPane(Expense expense) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        // A SlidableAction can have an icon and/or a label.
        SlidableAction(
          onPressed: (_) async {
            await context
                .read<ExpenseViewModel>()
                .archiveExpense(expense: expense);
          },
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: Icons.archive,
        ),

        SlidableAction(
          onPressed: (_) {
            context.read<ExpenseViewModel>().removeExpense(expense);
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
        ),

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Day-wise Expenses"),
      ),
      body: Consumer<ExpenseViewModel>(builder: (ctx, model, _) {
        List<DayCategoryExpense> _data = getData();
        return _data.isEmpty
            ? Center(
                child: Text(
                    "No Expenses on " + DateFormat('dd/MM/yyyy').format(_date)))
            : ListView.separated(
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                "Swipe tile for options...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: DateTimePicker(
                                style: const TextStyle(fontSize: 12),
                                type: DateTimePickerType.date,
                                initialValue: _date.toString(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                icon: const Icon(Icons.event),
                                onChanged: (val) {
                                  _date = DateTime.parse(val);
                                  setState(() {});
                                },
                              ),
                            )
                          ]),
                    );
                  }
                  List<Expense> _expenses = _data[index - 1].expenses;
                  return ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _data[index - 1].category.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  "\u{20B9}${_data[index - 1].category.totalExpense}",
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
                            startActionPane: _getActionPane(_expenses[i]),
                            endActionPane: _getActionPane(_expenses[i]),
                            closeOnScroll: true,
                            child: ListTile(
                              subtitle: Text(DateFormat('hh:mm a')
                                  .format(_expenses[i].time)),
                              leading: Text("\u{20B9}${_expenses[i].amount}"),
                              title: Text(_expenses[i].description),
                              trailing: Text(_expenses[i].paymentType),
                            ),
                          ),
                      ]);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _data.length + 1);
      }),
    );
  }
}
