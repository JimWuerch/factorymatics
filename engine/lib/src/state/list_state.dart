import 'dart:collection';

import 'package:engine/engine.dart';
import 'list_change.dart';

// ignore: prefer_mixin
class ListState<T> extends GameStateBase with IterableMixin<T> {
  final List<T> _list;

  ListState(Game game, String label, {StateVarCallback onChanged})
      : _list = <T>[],
        super(game, label, onChanged);

  void add(T value) {
    ListChange<T>.add(this, value, _list.length);
  }

  void insert(T value, int index) {
    ListChange<T>.add(this, value, index);
  }

  bool remove(T value) {
    if (!_list.contains(value)) return false;
    ListChange<T>.remove(this, _list.indexOf(value));
    return true;
  }

  T removeAt(int index) {
    var ret = _list[index];
    ListChange<T>.remove(this, index);
    return ret;
  }

  void clear() {
    game.changeStack.group();
    for (var i = _list.length - 1; i >= 0; i++) {
      removeAt(i);
    }
    game.changeStack.commit();
  }

  int get length => _list.length;

  bool get isEmpty => _list.isEmpty;

  int indexOf(T value) => _list.indexOf(value);

  T operator [](int index) => _list[index];

  void operator []=(int index, T value) {
    ListChange<T>.update(this, value, index);
  }

  Iterator<T> get iterator => _list.iterator;

  void change(T value, int index, ListChangeOperation operation) {
    switch (operation) {
      case ListChangeOperation.add:
        _list.insert(index, value);
        break;
      case ListChangeOperation.remove:
        _list.removeAt(index);
        break;
      case ListChangeOperation.update:
        _list[index] = value;
        break;
    }
  }
}
