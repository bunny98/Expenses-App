import 'package:expense/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryEncapsulator {
  late Set<Category> _categories;
  late Category _chosenCategory;
  late Category _defaultCategory;

  CategoryEncapsulator(
      {required Set<Category> categories, required Category defaultCategory}) {
    _categories = categories;
    _defaultCategory = defaultCategory;
  }

  factory CategoryEncapsulator.defaultValue() {
    Set<Category> _categorySet = {};
    var _uuid = Uuid();
    _categorySet.add(Category(id: _uuid.v1(), name: "Food"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Grocery"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Investments"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Rent"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Travel"));
    _categorySet.add(Category(id: _uuid.v1(), name: "Entertainment"));

    return CategoryEncapsulator(
        categories: _categorySet, defaultCategory: _categorySet.first);
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
}
