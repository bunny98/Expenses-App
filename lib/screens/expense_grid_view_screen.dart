import 'package:expense/models/category.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_expense_screen.dart';

class ExpenseGridViewScreen extends StatefulWidget {
  const ExpenseGridViewScreen({Key? key, required this.scrollController})
      : super(key: key);
  final ScrollController scrollController;

  @override
  _ExpenseGridViewScreenState createState() => _ExpenseGridViewScreenState();
}

class _ExpenseGridViewScreenState extends State<ExpenseGridViewScreen> {
  final _textStyle = const TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, model, _) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
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
                                    category:
                                        model.getAllCategories()[index])));
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              model.getAllCategories()[index].name,
                              style: _textStyle,
                            ),
                            Text(
                              "\u{20B9} ${model.getAllCategories()[index].totalExpense}",
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
      ),
    );
  }
}
