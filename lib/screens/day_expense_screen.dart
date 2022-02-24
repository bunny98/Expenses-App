import 'package:date_time_picker/date_time_picker.dart';
import 'package:expense/models/day_category_expense.dart';
import 'package:expense/models/day_expense.dart';
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

  Future<List<DayCategoryExpense>> getData() async {
    DayCategoryExpenseEncapsulator _encap = DayCategoryExpenseEncapsulator(
        expenseViewModel: _expenseViewModel, date: _date);
    return await _encap.getData();
  }

  ActionPane _getActionPane(DayExpense dayExp) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: !dayExp.isArchived
          ? [
              // A SlidableAction can have an icon and/or a label.
              // SlidableAction(
              //   onPressed: (_) async {
              //     await context
              //         .read<ExpenseViewModel>()
              //         .archiveExpense(expense: dayExp.expense);
              //   },
              //   backgroundColor: Colors.black,
              //   foregroundColor: Colors.white,
              //   icon: Icons.archive,
              // ),

              SlidableAction(
                onPressed: (_) {
                  context
                      .read<ExpenseViewModel>()
                      .removeExpense(dayExp.expense);
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
                              expense: dayExp.expense,
                              mode: AddExpenseMode.EDIT,
                            ))),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: Icons.edit,
              ),
            ]
          : [
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                label: "Archived Expense",
              )
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
        return FutureBuilder(
            future: getData(),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              List<DayCategoryExpense> _data =
                  snap.data as List<DayCategoryExpense>;
              return ListView.separated(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(children: [
                          Row(
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
                          if (_data.isEmpty)
                            const SizedBox(
                              height: 20,
                            ),
                          if (_data.isEmpty)
                            Center(
                                child: Text("No Expenses on " +
                                    DateFormat('dd/MM/yyyy').format(_date)))
                        ]),
                      );
                    }

                    List<DayExpense> _dayExp = _data[index - 1].dayExpenses;
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
                          for (int i = 0; i < _dayExp.length; ++i)
                            Slidable(
                              key: ValueKey(_dayExp[i].expense.id),
                              startActionPane: _getActionPane(_dayExp[i]),
                              endActionPane: _getActionPane(_dayExp[i]),
                              closeOnScroll: true,
                              child: ListTile(
                                subtitle: Text(DateFormat('hh:mm a')
                                    .format(_dayExp[i].expense.time)),
                                leading: Text(
                                    "\u{20B9}${_dayExp[i].expense.amount}"),
                                title: Text(_dayExp[i].expense.description),
                                trailing: Text(_dayExp[i].expense.paymentType),
                              ),
                            ),
                        ]);
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: _data.length + 1);
            });
      }),
    );
  }
}
