import 'dart:math';

import 'package:expense/models/category.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/models/payment_type.dart';
import 'package:expense/models/upi_category.dart';
import 'package:expense/models/upi_payment.dart';
import 'package:expense/screens/home_page.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/utils/transaction_status.dart';
import 'package:expense/utils/upi_apps_encap.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PayFromQRScreen extends StatefulWidget {
  const PayFromQRScreen({Key? key, required this.upiPayment}) : super(key: key);
  final UPIPayment upiPayment;

  @override
  _PayFromQRScreenState createState() => _PayFromQRScreenState();
}

class _PayFromQRScreenState extends State<PayFromQRScreen> {
  late GlobalKey<FormState> _formKey;
  late ExpenseViewModel _expenseViewModel;
  late Future<Category?> _getDefaultCategoryFuture;
  late List<Widget> _categoryWidgets;
  late List<Widget> _upiAppsWidgets;
  late UpiAppsEncapsulator _upiAppsEncapsulator;
  late CategoryEncapsulator _categoryEncapsulator;
  late Category? _defaultCategory;
  late bool _isLoading;
  late String _errorString;
  final _foregroundColor = MaterialStateProperty.all<Color>(Colors.white);
  final _backgroundColor = MaterialStateProperty.all<Color>(Colors.black);

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _expenseViewModel = context.read<ExpenseViewModel>();
    _getDefaultCategoryFuture = getUPICategory();
    _defaultCategory = null;
    _isLoading = false;
    _errorString = "";
    _categoryEncapsulator = _expenseViewModel.getCategoryEncapsulator();
    _categoryEncapsulator.setDefaultCategory();
    PaymentTypes.choosePaymentType("UPI");
    _upiAppsEncapsulator = _expenseViewModel.getUpiAppEncapsulator();
    _setCategoryWidgets();
    _setUpiAppsWidgets();
  }

  Future<Category?> getUPICategory() async {
    return await context
        .read<ExpenseViewModel>()
        .getCategoryForUpiId(widget.upiPayment.upiID);
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

  void _setUpiAppsWidgets() {
    _upiAppsWidgets = [];
    for (var element in _upiAppsEncapsulator.getAppsList()) {
      _upiAppsWidgets.add(ElevatedButton(
          onPressed: () {
            _upiAppsEncapsulator.chooseUpiApp(element);
            setState(() {
              _setUpiAppsWidgets();
            });
          },
          child: Text(element.name),
          style: ButtonStyle(
              foregroundColor: _upiAppsEncapsulator.getChosenUpiApp() == element
                  ? _foregroundColor
                  : _backgroundColor,
              backgroundColor: _upiAppsEncapsulator.getChosenUpiApp() == element
                  ? _backgroundColor
                  : _foregroundColor,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.black))))));
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorString = "";
      });
      String expenseId = Random().nextInt(10).toString() +
          const Uuid().v1().replaceAll("-", "").substring(0, 11);
      TransactionStatus status = await _expenseViewModel.initiateUpiTransaction(
          upiPayment: widget.upiPayment, expenseId: expenseId);
      _errorString =
          status == TransactionStatus.FAILURE ? "ERROR OCCURED!" : "";
      if (_errorString.isEmpty) {
        Category _chosenCategory = _categoryEncapsulator.getChosenCategory();
        await _expenseViewModel.addExpense(
          Expense(
              id: expenseId,
              amount: widget.upiPayment.amount.toInt(),
              description: widget.upiPayment.recipientName,
              paymentType: PaymentTypes.getChosenPaymentType(),
              time: DateTime.now(),
              categoryId: _chosenCategory.id),
        );
        if (_defaultCategory == null || (_defaultCategory != _chosenCategory)) {
          await _expenseViewModel.addUpiCategory(UPICategory(
              upiId: widget.upiPayment.upiID, categoryId: _chosenCategory.id));
        }
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (ctx) => const MyHomePage()),
            (route) => false);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UPI Transaction"),
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 30),
                        keyboardType: TextInputType.number,
                        onSaved: (amt) {
                          if (amt!.isNotEmpty && double.tryParse(amt) != null) {
                            widget.upiPayment.amount = double.parse(amt);
                          }
                        },
                        decoration: const InputDecoration(
                          prefixText: "\u{20B9} ",
                          hintText: 'Amount',
                        ),
                        validator: (ip) {
                          if (ip!.isEmpty ||
                              double.tryParse(ip) == null ||
                              double.parse(ip) <= 0) {
                            return "Are you kidding me?";
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        initialValue: "To ${widget.upiPayment.recipientName}",
                        textAlign: TextAlign.center,
                        onSaved: (des) {
                          widget.upiPayment.recipientName = des!;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Description',
                        ),
                      ),
                    ),
                    const Text("Category"),
                    FutureBuilder(
                        future: _getDefaultCategoryFuture,
                        builder: (ctx, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const CircularProgressIndicator();
                          }
                          if (snap.hasData) {
                            _categoryEncapsulator
                                .chooseCategory(snap.data as Category);
                            _defaultCategory = snap.data as Category;
                            _setCategoryWidgets();
                          }
                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            children: _categoryWidgets,
                          );
                        }),
                    const Text("Upi App for Payment"),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: _upiAppsWidgets,
                    ),
                    if (_errorString.isNotEmpty)
                      Text(
                        _errorString,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                          onPressed: _onSubmit,
                          child: const Text("Submit"),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(15)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
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

  @override
  void dispose() {
    PaymentTypes.setDefaultPaymentType();
    _categoryEncapsulator.setDefaultCategory();
    super.dispose();
  }
}
