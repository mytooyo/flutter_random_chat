import 'package:flutter/material.dart';

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E> initialItems = const [],
  })  : assert(removedItemBuilder != null),
        _items = List<E>.from(initialItems);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList?.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList?.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            removedItemBuilder(removedItem, context, animation),
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);

  List<E> where(Function func) =>
      _items.where((element) => func(element)).toList();

  void update(int index, E item) => _items[index] = item;
}
