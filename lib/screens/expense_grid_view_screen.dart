import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_expense_screen.dart';

class ExpenseGridViewScreen extends StatefulWidget {
  const ExpenseGridViewScreen({Key? key}) : super(key: key);

  @override
  _ExpenseGridViewScreenState createState() => _ExpenseGridViewScreenState();
}

class _ExpenseGridViewScreenState extends State<ExpenseGridViewScreen> {
  final _textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, model, child) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total expenditure in last month: \u{20B9}${model.getTotalExpenditure()}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 4.0,
                mainAxisExtent: 150),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  elevation: 15,
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => CategoryExpenseScreen(
                                  category: model.getAllCategories()[index])));
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            model.getAllCategories()[index],
                            style: _textStyle,
                          ),
                          Text(
                            "\u{20B9} ${model.getTotalExpenseOfCategory(model.getAllCategories()[index])}",
                            style: _textStyle,
                          ),
                        ]),
                  ),
                );
              },
              childCount: model.getAllCategories().length,
            ),
          ),
        ],
      ),
    );
  }
}
