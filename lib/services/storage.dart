import 'package:expense/models/archive_params.dart';
import 'package:expense/models/category.dart';
import 'package:expense/models/upi_category.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/expense.dart';
import 'package:flutter/material.dart';

abstract class Storage {
  Future<void> init({int daysToKeepRecord = -1});
  Future<void> clearStorage();
  Future<void> addExpense(Expense expense, Category category);
  Future<void> removeExpense(Expense expense, Category category);
  Future<void> editExpense(
      {required Expense oldExpense,
      required Expense newExpense,
      required Category oldCategory,
      required Category newCategory});
  Future<void> addCategory(Category category);
  Future<void> removeCategory(Category category);
  Future<List<Expense>> getAllExpenses();
  Future<CategoryEncapsulator> getCategoryEncapsulator();
  Future<void> importData({required BuildContext context});
  Future<void> exportData({required BuildContext context});
  Future<UPICategory?> getUpiCategory({required String upiId});
  Future<void> addUpiCategory(UPICategory upiCategory);
  Future<void> updateUpiCategory(UPICategory upiCategory);
  Future<void> archiveAllExpenses();
  Future<void> archiveExpense({required Expense expense});
  Future<List<Expense>> getAllArchivedExpensesOfCategory(
      {required Category category});
  Future<void> unArchiveExpense(
      {required Expense expense, required Category category});
  Future<void> saveArchiveParams({required ArchiveParams archiveParams});
  ArchiveParams? getArchiveParams();
}
