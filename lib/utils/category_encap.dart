import 'package:expense/models/category.dart';
import 'package:expense/models/metadata.dart';
import 'package:expense/models/metadata_types.dart';
import 'package:expense/models/month_to_expense.dart';
import 'package:expense/models/monthly_cat_expense.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryEncapsulator {
  late Set<Category> _categories;
  late Category _chosenCategory;
  late Category _defaultCategory;

  final List _monthsStrList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  late List<String> _months;
  late List<MonthlyCatExpense> _monthlyCatExpenseList;
  late List<MonthToExpense> _totalMonthlyExpenseList;

  CategoryEncapsulator(
      {required Set<Category> categories,
      required Category defaultCategory,
      required List<Metadata> metadataList}) {
    _categories = categories;
    _defaultCategory = defaultCategory;

    /*
    GRAPH DATA CALCULATION FROM METADATA
    */
    _buildMonthlyCatExpenseList(metadataList);
    _buildTotalMonthlyExpense();
  }

  factory CategoryEncapsulator.defaultValue() {
    Set<Category> _categorySet = {};
    var _uuid = const Uuid();
    _categorySet.add(Category(id: _uuid.v1(), name: "Food"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Grocery"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Investments"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Rent"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Travel"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Entertainment"));

    return CategoryEncapsulator(
        categories: _categorySet,
        defaultCategory: _categorySet.first,
        metadataList: []);
  }

  List<Category> getCategoryList() => _categories.toList();

  void addCategory({required Category category}) {
    _categories.add(category);
  }

  void removeCategory(Category category) {
    _categories.remove(category);
  }

  void chooseCategory(Category category) {
    _chosenCategory = category;
  }

  void setDefaultCategory() {
    _chosenCategory = getDefaultCategory();
  }

  void overrideCategory(Category category) {
    _categories.removeWhere((element) => element.id == category.id);
    _categories.add(category);
  }

  Category getDefaultCategory() => _defaultCategory;

  Category getChosenCategory() => _chosenCategory;

  Category getCategoryFromId(String id) =>
      _categories.where((element) => element.id == id).first;

  List<MonthlyCatExpense> getMonthlyCatExpense() => _monthlyCatExpenseList;
  List<MonthToExpense> getTotalMonthlyExpense() => _totalMonthlyExpenseList;
  List<String> getMonths() => _months;

  List<Metadata> getLatestMetadata(int time) {
    return getCategoryList()
        .map((e) => Metadata(
            data: "${e.totalExpense}",
            metadataType: MetadataType.CATEGORY_DATA,
            time: time,
            typeSpecificId: e.id))
        .toList();
  }

  void _buildTotalMonthlyExpense() {
    _totalMonthlyExpenseList = [];
    List<int> expenses = List.filled(_months.length, 0);
    for (var element in _monthlyCatExpenseList) {
      List<int> exp = element.getData().map((e) => e.expense).toList();
      for (int i = 0; i < exp.length; ++i) {
        expenses[i] += exp[i];
      }
    }
    for (int i = 0; i < expenses.length; ++i) {
      _totalMonthlyExpenseList.add(MonthToExpense(_months[i], expenses[i]));
    }
  }

  void _buildMonthlyCatExpenseList(List<Metadata> metadataList) {
    debugPrint("METADATA LIST LEN ${metadataList.length}");
    DateTime _now = DateTime.now();
    List<int> _monthsIntList = metadataList.map((e) => e.time).toSet().toList();
    _monthsIntList.add(_now.millisecondsSinceEpoch);
    _monthsIntList.sort();
    _months = _monthsIntList.map((e) {
      DateTime _time = DateTime.fromMillisecondsSinceEpoch(e);
      return getMonthStr(_time);
    }).toList();

    //Y-AXIS CALCULATION
    Map<String, Map<int, int>> categoryToTimeExpense = {};
    for (var element in metadataList) {
      if (categoryToTimeExpense.containsKey(element.typeSpecificId)) {
        categoryToTimeExpense[element.typeSpecificId]!
            .putIfAbsent(element.time, () => int.parse(element.data));
      } else {
        categoryToTimeExpense.putIfAbsent(element.typeSpecificId,
            () => {element.time: int.parse(element.data)});
      }
    }

    getCategoryList().forEach((element) {
      if (categoryToTimeExpense.containsKey(element.id)) {
        categoryToTimeExpense[element.id]!
            .putIfAbsent(_monthsIntList.last, () => element.totalExpense);
      } else {
        categoryToTimeExpense.putIfAbsent(
            element.id, () => {_monthsIntList.last: element.totalExpense});
      }
    });

    Map<String, MonthlyCatExpense> catIdToMonthlyCatExpense = {};
    for (var element in categoryToTimeExpense.keys) {
      catIdToMonthlyCatExpense.putIfAbsent(
          element,
          () => MonthlyCatExpense(
              categoryName: getCategoryFromId(element).name,
              categoryId: element));
    }

    categoryToTimeExpense.forEach((key, value) {
      for (int i = 0; i < _monthsIntList.length; ++i) {
        catIdToMonthlyCatExpense[key]!
            .addExpenseAmount(_months[i], value[_monthsIntList[i]]!);
      }
    });

    _monthlyCatExpenseList = catIdToMonthlyCatExpense.values.toList();
    //LENGTH TESTING
    for (var element in _monthlyCatExpenseList) {
      assert(element.getData().length == _months.length);
    }
  }

  String getMonthStr(DateTime dateTime) {
    return "${_monthsStrList[dateTime.month - 1]}'${dateTime.year % 100}";
  }
}
