import 'package:expense/utils/category_encap.dart';
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
  late CategoryEncapsulator _categoryEncapsulator;
  late List<Widget> _categoryWidgets;
  late bool _isEditing;
  late Future _initialFuture;
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
    _categoryEncapsulator =
        context.read<ExpenseViewModel>().getCategoryEncapsulator();
    if (_isEditing) {
      _categoryEncapsulator.chooseCategory(
          _categoryEncapsulator.getCategoryFromId(widget.expense!.categoryId));
      PaymentTypes.choosePaymentType(widget.expense!.paymentType);
    } else {
      _categoryEncapsulator.setDefaultCategory();
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
    for (var element in _categoryEncapsulator.getCategoryList()) {
      _categoryWidgets.add(ElevatedButton(
          onPressed: () {
            _categoryEncapsulator.chooseCategory(element);
            setState(() {
              _setCategoryWidgets();
            });
          },
          child: Text(element.name),
          style: ButtonStyle(
              foregroundColor:
                  _categoryEncapsulator.getChosenCategory() == element
                      ? _foregroundColor
                      : _backgroundColor,
              backgroundColor:
                  _categoryEncapsulator.getChosenCategory() == element
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
          categoryId: _categoryEncapsulator.getChosenCategory().id);
      await context.read<ExpenseViewModel>().editExpense(
          oldExpense: widget.expense!,
          newExpense: obj,
          oldCategory: _categoryEncapsulator
              .getCategoryFromId(widget.expense!.categoryId),
          newCategory: _categoryEncapsulator.getChosenCategory());
    } else {
      obj = Expense(
          id: _uuid.v1(),
          amount: _data[_amountKey],
          description: _data[_descriptionKey].toString().isEmpty
              ? "Nil"
              : _data[_descriptionKey],
          paymentType: PaymentTypes.getChosenPaymentType(),
          time: DateTime.now(),
          categoryId: _categoryEncapsulator.getChosenCategory().id);
      context
          .read<ExpenseViewModel>()
          .addExpense(obj, _categoryEncapsulator.getChosenCategory());
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _categoryEncapsulator.setDefaultCategory();
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
