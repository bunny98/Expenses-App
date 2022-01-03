import 'package:expense/models/category.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({Key? key}) : super(key: key);

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late List<Widget> _categoryWidgetList;

  @override
  void initState() {
    super.initState();
  }

  Future<String> showInputDialog() async {
    String _newCategory = "";
    await Alert(
        context: context,
        title: "Input Dialog",
        content: Column(
          children: <Widget>[
            TextField(
              onChanged: (cat) => _newCategory = cat,
              decoration: const InputDecoration(
                icon: Icon(Icons.category),
                labelText: 'Enter new category',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
    return _newCategory;
  }

  Future<bool> showConfirmActionDialog() async {
    bool _delete = false;
    await Alert(
      context: context,
      type: AlertType.warning,
      title: "ALERT",
      desc:
          "Deleting this category will also delete all the expenses of this category. Are you sure?",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Categories"),
      ),
      body: Consumer<ExpenseViewModel>(builder: (ctx, model, _) {
        _categoryWidgetList = [];
        for (var element in model.getAllCategories()) {
          _categoryWidgetList.add(ListTile(
            leading:
                Text("${element.name}  -- \u{20B9}${element.totalExpense}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if (await showConfirmActionDialog()) {
                  model.removeCategory(element);
                  // setState(() {});
                }
              },
            ),
          ));
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 8,
                  child: ElevatedButton(
                    onPressed: () async {
                      String name = await showInputDialog();
                      if (name.isNotEmpty) {
                        model.addCategory(
                            Category(id: const Uuid().v1(), name: name));
                      }
                    },
                    child: const Text("Add"),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(_categoryWidgetList),
            )
          ],
        );
      }),
    );
  }
}
