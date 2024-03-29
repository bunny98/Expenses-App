import 'package:expense/models/category.dart';
import 'package:expense/utils/add_expense_screen_enum.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_type.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:date_time_picker/date_time_picker.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen(
      {Key? key, this.expense, this.category, required this.mode})
      : super(key: key);
  final Expense? expense;
  final Category? category;
  final AddExpenseMode mode;

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
  late bool _isAddingFromCategoryPage;
  late ExpenseViewModel _expenseViewModel;
  final _uuid = const Uuid();
  final String _amountKey = "amt";
  final String _descriptionKey = "des";
  final String _dateTimeKey = "time";
  final _foregroundColor = MaterialStateProperty.all<Color>(Colors.white);
  final _backgroundColor = MaterialStateProperty.all<Color>(Colors.black);

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _expenseViewModel = context.read<ExpenseViewModel>();
    _isEditing = widget.mode == AddExpenseMode.EDIT;
    _isAddingFromCategoryPage =
        widget.mode == AddExpenseMode.ADDITION_FROM_CATEGORY_PAGE;
    _data = {};
    _categoryEncapsulator = _expenseViewModel.getCategoryEncapsulator();

    switch (widget.mode) {
      case AddExpenseMode.EDIT:
        _data.putIfAbsent(_descriptionKey, () => widget.expense!.description);
        _data.putIfAbsent(_amountKey, () => widget.expense!.amount);
        _data.putIfAbsent(_dateTimeKey, () => widget.expense!.time);
        _categoryEncapsulator.chooseCategory(_categoryEncapsulator
            .getCategoryFromId(widget.expense!.categoryId));
        PaymentTypes.choosePaymentType(widget.expense!.paymentType);
        _setCategoryWidgets();
        break;
      case AddExpenseMode.ADDITION_FROM_CATEGORY_PAGE:
        _data.putIfAbsent(_descriptionKey, () => "");
        _data.putIfAbsent(_amountKey, () => 0);
        _data.putIfAbsent(_dateTimeKey, () => DateTime.now());
        _categoryEncapsulator.chooseCategory(widget.category!);
        PaymentTypes.setDefaultPaymentType();
        break;
      default:
        _data.putIfAbsent(_descriptionKey, () => "");
        _data.putIfAbsent(_amountKey, () => 0);
        _data.putIfAbsent(_dateTimeKey, () => DateTime.now());
        _categoryEncapsulator.setDefaultCategory();
        PaymentTypes.setDefaultPaymentType();
        _setCategoryWidgets();
    }

    _setPaymentMethodWidgets();
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
          child: Text(
            element,
            style: TextStyle(fontSize: 10),
          ),
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
          child: Text(
            element.name,
            style: TextStyle(fontSize: 10),
          ),
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

    switch (widget.mode) {
      case AddExpenseMode.EDIT:
        obj = Expense(
            id: widget.expense!.id,
            amount: _data[_amountKey],
            description: _data[_descriptionKey].toString().isEmpty
                ? "Nil"
                : _data[_descriptionKey],
            paymentType: PaymentTypes.getChosenPaymentType(),
            time: _data[_dateTimeKey],
            categoryId: _categoryEncapsulator.getChosenCategory().id);
        await _expenseViewModel.editExpense(
            oldExpense: widget.expense!,
            newExpense: obj,
            oldCategory: _categoryEncapsulator
                .getCategoryFromId(widget.expense!.categoryId),
            newCategory: _categoryEncapsulator.getChosenCategory());
        break;
      default:
        obj = Expense(
            id: _uuid.v1(),
            amount: _data[_amountKey],
            description: _data[_descriptionKey].toString().isEmpty
                ? "Nil"
                : _data[_descriptionKey],
            paymentType: PaymentTypes.getChosenPaymentType(),
            time: _data[_dateTimeKey],
            categoryId: _categoryEncapsulator.getChosenCategory().id);
        await _expenseViewModel.addExpense(obj);
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
                    const Text(
                      "Payment Method",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: _paymentMethodWidgets,
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    if (_isAddingFromCategoryPage)
                      Text(
                        "Category: ${widget.category!.name}",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    if (!_isAddingFromCategoryPage)
                      const Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    if (!_isAddingFromCategoryPage)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5,
                        children: _categoryWidgets,
                      ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: DateTimePicker(
                        style: const TextStyle(fontSize: 14),
                        type: DateTimePickerType.dateTime,
                        // dateMask: 'd MMM, yyyy',
                        initialValue: _data[_dateTimeKey].toString(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        icon: const Icon(Icons.event),
                        dateLabelText: 'Date',
                        timeLabelText: "Time",
                        onChanged: (val) =>
                            _data[_dateTimeKey] = DateTime.parse(val),
                      ),
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
