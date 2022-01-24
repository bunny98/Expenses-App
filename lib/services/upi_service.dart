import 'dart:math';

import 'package:expense/models/upi_payment.dart';
import 'package:expense/utils/transaction_status.dart';
import 'package:expense/utils/upi_apps_encap.dart';
import 'package:flutter/cupertino.dart';
import 'package:upi_india/upi_india.dart';

class UpiService {
  late UpiAppsEncapsulator _upiAppsEncapsulator;
  late UpiIndia _upiIndia;

  Future<void> init() async {
    _upiIndia = UpiIndia();
    _upiAppsEncapsulator = UpiAppsEncapsulator<UpiApp>(
      apps: await _upiIndia.getAllUpiApps(mandatoryTransactionId: false),
    );
  }

  Future<TransactionStatus> initiateTransaction(
      {required UPIPayment upiPayment, required String expenseId}) async {
    TransactionStatus status = TransactionStatus.SUCCESS;
    try {
      UpiResponse res = await _upiIndia.startTransaction(
          amount: upiPayment.amount,
          app: _upiAppsEncapsulator.getChosenUpiApp(),
          receiverUpiId: upiPayment.upiID,
          receiverName: upiPayment.recipientName,
          transactionRefId: expenseId);
      if (res.status != UpiPaymentStatus.SUCCESS) {
        status = TransactionStatus.FAILURE;
      }
    } catch (ex) {
      status = TransactionStatus.FAILURE;
    }
    return status;
  }

  UpiAppsEncapsulator getUpiAppEncapsulator() => _upiAppsEncapsulator;
}
