import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense/screens/add_edit_expense_screen.dart';
import 'package:expense/screens/charts_screen.dart';
import 'package:expense/screens/edit_category_screen.dart';
import 'package:expense/screens/expense_grid_view_screen.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _bottomNavIndex;
  final List<Widget> _widgetList = [
    const ExpenseGridViewScreen(),
    const ChartScreen()
  ];
  static const String _editCategoryOptionString = "Edit Categories";
  static const String _deleteAllDataOptionString = "Delete All Data";

  @override
  void initState() {
    _bottomNavIndex = 0;
    super.initState();
  }

  Future<bool> showConfirmActionDialog() async {
    bool _delete = false;
    await Alert(
      context: context,
      type: AlertType.warning,
      title: "ALERT",
      desc: "Are you sure you want to delete all data?",
      buttons: [
        DialogButton(
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _delete = true;
            Navigator.pop(context);
          },
          color: const Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: const Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _delete = false;
            Navigator.pop(context);
          },
          gradient: const LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
    return _delete;
  }

  void _handleClick(String choice) async {
    switch (choice) {
      case _editCategoryOptionString:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EditCategoryScreen()));
        break;
      case _deleteAllDataOptionString:
        if (await showConfirmActionDialog()) {
          context.read<ExpenseViewModel>().clearStorage();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleClick,
            itemBuilder: (BuildContext context) {
              return {_editCategoryOptionString, _deleteAllDataOptionString}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                        child: choice == _editCategoryOptionString
                            ? const Icon(
                                Icons.edit,
                                color: Colors.black,
                              )
                            : const Icon(Icons.delete, color: Colors.black)),
                    Text(choice)
                  ]),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _widgetList[_bottomNavIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.home,
          Icons.pie_chart,
        ],
        inactiveColor: Colors.grey,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() {
          _bottomNavIndex = index;
        }),
        //other params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditExpenseScreen())),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
