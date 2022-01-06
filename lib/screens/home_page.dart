import 'package:expense/screens/add_edit_expense_screen.dart';
import 'package:expense/screens/charts_screen.dart';
import 'package:expense/screens/edit_category_screen.dart';
import 'package:expense/screens/expense_grid_view_screen.dart';
import 'package:expense/screens/qr_scanner.dart';
import 'package:expense/utils/add_expense_screen_enum.dart';
import 'package:expense/utils/global_func.dart';
import 'package:expense/utils/popup_menu_item_encap.dart';
import 'package:expense/utils/upi_apps_encap.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PoppupMenuEncapsulator<String> _poppupMenuEncapsulator;

  @override
  void initState() {
    _poppupMenuEncapsulator = PoppupMenuEncapsulator<String>();
    _poppupMenuEncapsulator.addItem(
        key: "Edit Categories",
        onClick: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditCategoryScreen()));
        });
    _poppupMenuEncapsulator.addItem(
        key: "Export All Data",
        onClick: () {
          context.read<ExpenseViewModel>().exportData(context);
        });
    _poppupMenuEncapsulator.addItem(
        key: "Import Data",
        onClick: () async {
          if (await showConfirmActionDialog(
              msg:
                  "This will add the imported data to your current data. Are you sure?",
              context: context)) {
            context.read<ExpenseViewModel>().importData(context);
          }
        });
    _poppupMenuEncapsulator.addItem(
        key: "Delete All Data",
        onClick: () async {
          if (await showConfirmActionDialog(
              msg: "Are you sure you want to delete all data?",
              context: context)) {
            context.read<ExpenseViewModel>().clearStorage();
          }
        });
    super.initState();
  }

  List<Widget> getDisplayWidget(ScrollController scrollController) {
    return [
      ExpenseGridViewScreen(scrollController: scrollController),
      ChartScreen(
        scrollController: scrollController,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Expenses"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _poppupMenuEncapsulator.getOnclickFunction(),
              itemBuilder: (BuildContext context) =>
                  _poppupMenuEncapsulator.getItems(),
            ),
          ],
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Consumer<ExpenseViewModel>(
                    builder: (ctx, model, _) => Text(
                      "\u{20B9}${model.getTotalExpenditure()}",
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // if (context
                    //     .read<ExpenseViewModel>()
                    //     .getUpiAppEncapsulator()
                    //     .getAppsList()
                    //     .isNotEmpty) {
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (ctx) => const QRScannerWidget()));
                    // } else {
                    //   showToast("No UPI App Installed in your phone!");
                    // }
                    showToast("Feature not supported yet");
                  },
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.black,
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                    backgroundColor: MaterialStateProperty.all(
                        Colors.white), // <-- Button color
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.grey;
                      } // <-- Splash color
                    }),
                  ),
                )
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () => showToast("Feature not coded yet."),
                          child: const Text(
                            "Sync with messages",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: const BorderSide(
                                          color: Colors.white))))),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddEditExpenseScreen(
                                      mode: AddExpenseMode.NEW_ADDITION,
                                    ))),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(10)),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white), // <-- Button color
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.grey;
                            } // <-- Splash color
                          }),
                        ),
                      )
                    ]),
              ),
            ]),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            builder: (context, controller) => Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Column(
                children: [
                  const TabBar(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      labelColor: Colors.black,
                      indicatorColor: Colors.grey,
                      indicatorWeight: 3,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                          child: Icon(
                            Icons.list_alt_rounded,
                          ),
                        ),
                        Tab(
                          child: Icon(Icons.pie_chart_outline_rounded),
                        )
                      ]),
                  const SizedBox(height: 10),
                  Expanded(
                      child:
                          TabBarView(children: getDisplayWidget(controller))),
                ],
              ),
            ),
          ),
        ]),
        // bottomNavigationBar: AnimatedBottomNavigationBar(
        //   icons: const [
        //     Icons.home,
        //     Icons.pie_chart,
        //   ],
        //   inactiveColor: Colors.grey,
        //   activeIndex: _bottomNavIndex,
        //   gapLocation: GapLocation.center,
        //   notchSmoothness: NotchSmoothness.verySmoothEdge,
        //   leftCornerRadius: 32,
        //   rightCornerRadius: 32,
        //   onTap: (index) => setState(() {
        //     _bottomNavIndex = index;
        //   }),
        //   //other params
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.white,
        //   onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => const AddEditExpenseScreen())),
        //   tooltip: 'Add Expense',
        //   child: const Icon(Icons.add, color: Colors.black),
        // ),
      ),
    );
  }
}
