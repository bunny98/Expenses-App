import 'package:expense/models/categories.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_type.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({Key? key, this.expense}) : super(key: key);
  final Expense? expense;

  @override
  _AddEditExpenseScreenState createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  late GlobalKey<FormState> _formKey;
  late Map<String, dynamic> _data;
  late List<Widget> _paymentMethodWidgets;
  late Categories _category;
  late List<Widget> _categoryWidgets;
  late bool _isEditing;
  final _uuid = const Uuid();
  final String _amountKey = "amt";
  final String _descriptionKey = "des";
  final _foregroundColor = MaterialStateProperty.all<Color>(Colors.white);
  final _backgroundColor = MaterialStateProperty.all<Color>(Colors.black);

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _isEditing = widget.expense != null;
    _data = {};
    _data.putIfAbsent(
        _descriptionKey, () => _isEditing ? widget.expense!.description : "");
    _data.putIfAbsent(
        _amountKey, () => _isEditing ? widget.expense!.amount : 0);
    _category = context.read<ExpenseViewModel>().getCategories();

    if (_isEditing) {
      _category.chooseCategory(widget.expense!.category);
      PaymentTypes.choosePaymentType(widget.expense!.paymentType);
    } else {
      _category.setDefaultCategory();
      PaymentTypes.setDefaultPaymentType();
    }

    _setPaymentMethodWidgets();
    _setCategoryWidgets();
  }

  void _setPaymentMethodWidgets() {
    _paymentMethodWidgets = [];
    for (var element in PaymentTypes.getPaymentTypesList()) {
      _paymentMethodWidgets.add(ElevatedButton(
          onPressed: () {
            PaymentTypes.choosePaymentType(element);
            setState(() {
              _setPaymentMethodWidgets();
            });
          },
          child: Text(element),
          style: ButtonStyle(
              foregroundColor: PaymentTypes.getChosenPaymentType() == element
                  ? _foregroundColor
                  : _backgroundColor,
              backgroundColor: PaymentTypes.getChosenPaymentType() == element
                  ? _backgroundColor
                  : _foregroundColor,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.black))))));
    }
  }

  void _setCategoryWidgets() {
    _categoryWidgets = [];
    for (var element in _category.getCategoryList()) {
      _categoryWidgets.add(ElevatedButton(
          onPressed: () {
            _category.chooseCategory(element);
            setState(() {
              _setCategoryWidgets();
            });
          },
          child: Text(element),
          style: ButtonStyle(
              foregroundColor: _category.getChosenCategory() == element
                  ? _foregroundColor
                  : _backgroundColor,
              backgroundColor: _category.getChosenCategory() == element
                  ? _backgroundColor
                  : _foregroundColor,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.black))))));
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    Expense obj;
    if (_isEditing) {
      obj = Expense(
          id: widget.expense!.id,
          amount: _data[_amountKey],
          description: _data[_descriptionKey].toString().isEmpty
              ? "Nil"
              : _data[_descriptionKey],
          paymentType: PaymentTypes.getChosenPaymentType(),
          time: widget.expense!.time,
          category: _category.getChosenCategory());
      await context.read<ExpenseViewModel>().editExpense(obj);
    } else {
      obj = Expense(
          id: _uuid.v1(),
          amount: _data[_amountKey],
          description: _data[_descriptionKey].toString().isEmpty
              ? "Nil"
              : _data[_descriptionKey],
          paymentType: PaymentTypes.getChosenPaymentType(),
          time: DateTime.now(),
          category: _category.getChosenCategory());
      context.read<ExpenseViewModel>().addExpense(obj);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _category.setDefaultCategory();
    PaymentTypes.setDefaultPaymentType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextFormField(
                        initialValue:
                            _isEditing ? _data[_amountKey].toString() : null,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 30),
                        keyboardType: TextInputType.number,
                        onSaved: (amt) {
                          if (amt!.isNotEmpty && int.tryParse(amt) != null) {
                            _data[_amountKey] = int.parse(amt);
                          }
                        },
                        decoration: const InputDecoration(
                          prefixText: "\u{20B9} ",
                          hintText: 'Amount',
                        ),
                        validator: (ip) {
                          if (ip!.isEmpty ||
                              int.tryParse(ip) == null ||
                              int.parse(ip) <= 0) {
                            return "Are you kidding me?";
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        initialValue:
                            _isEditing ? _data[_descriptionKey] : null,
                        textAlign: TextAlign.center,
                        onSaved: (des) {
                          if (des != null) _data[_descriptionKey] = des;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Description',
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    const Text("Payment Method"),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: _paymentMethodWidgets,
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    const Text("Category"),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: _categoryWidgets,
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text("Submit"),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(15)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(
                                        color: Colors.black))))),
                    // const Flexible(flex: 3, child: SizedBox()),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
