import 'package:flutter/material.dart';

class PoppupMenuEncapsulator<T> {
  late List<PopupMenuItem<T>> _items;
  late Map<T, Function> _onClickMap;

  PoppupMenuEncapsulator() {
    _items = [];
    _onClickMap = {};
  }

  void onClickFunction(T key) {
    _onClickMap[key]!.call();
  }

  void addItem({required T key, required Function onClick, String? title}) {
    _items.add(
      PopupMenuItem<T>(value: key, child: Text(title ?? key.toString())),
    );
    _onClickMap.putIfAbsent(key, () => onClick);
  }

  List<PopupMenuItem<T>> getItems() => _items;

  Function(T) getOnclickFunction() => onClickFunction;
}
