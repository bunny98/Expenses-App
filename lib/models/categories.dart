class Categories {
  late Set<String> _categories;
  late String _chosenCategory;

  Categories({Set<String>? categories}) {
    _categories = categories ??
        {"Food", "Grocery", "Investments", "Rent", "Travel", "Entertainment"};
    setDefaultCategory();
  }

  List<String> getCategoryList() => _categories.toList();

  void addCategory({String category = ""}) {
    if (category.isNotEmpty) {
      _categories.add(category);
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
  }

  void chooseCategory(String category) {
    _chosenCategory = category;
  }

  void setDefaultCategory() {
    _chosenCategory = getDefaultCategory();
  }

  String getDefaultCategory() => "Food";

  String getChosenCategory() => _chosenCategory;
}
