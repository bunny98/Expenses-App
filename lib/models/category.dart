import 'dart:convert';

class Category {
  final String id;
  final int totalExpense;
  final String name;

  Category({required this.id, this.totalExpense = 0, required this.name});

  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
        id: jsonData['id'],
        totalExpense: jsonData['totalExpense'],
        name: jsonData['name']);
  }

  factory Category.reduceAmountBy(Category category, int amount) => Category(
      id: category.id,
      name: category.name,
      totalExpense: category.totalExpense - amount);

  factory Category.increaseAmountBy(Category category, int amount) => Category(
      id: category.id,
      name: category.name,
      totalExpense: category.totalExpense + amount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalExpense': totalExpense,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, totalExpense: $totalExpense}';
  }

  String getPrimaryKeySearchCondition() => "id = \"$id\"";
  static String getPrimaryKeyName() => "id";
  static String encode(Category category) => json.encode(category.toMap());
  static Category decode(String category) =>
      Category.fromJson(json.decode(category));
  static String getSQLCreateDatatypes() =>
      "(id TEXT PRIMARY KEY, totalExpense INTEGER, name TEXT)";

  @override
  bool operator ==(other) {
    return (other is Category) && (other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
