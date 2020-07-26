import 'package:engine/engine.dart';

enum ListChangeOperation { add, remove, update }

class ListChange<T> extends Change {
  final ListState<T> state;
  final T item;
  final T oldItem;
  final int index;
  final ListChangeOperation operation;

  ListChange.add(this.state, this.item, this.index)
      : operation = ListChangeOperation.add,
        oldItem = null {
    state.game.changeStack.add(this);
  }

  ListChange.remove(this.state, this.index)
      : item = state[index],
        operation = ListChangeOperation.remove,
        oldItem = null {
    state.game.changeStack.add(this);
  }

  ListChange.update(this.state, this.item, this.index)
      : operation = ListChangeOperation.update,
        oldItem = state[index] {
    state.game.changeStack.add(this);
  }

  @override
  void execute() {
    state.change(item, index, operation);
  }

  @override
  void undo() {
    ListChangeOperation op;
    switch (operation) {
      case ListChangeOperation.add:
        op = ListChangeOperation.remove;
        break;
      case ListChangeOperation.remove:
        op = ListChangeOperation.add;
        break;
      case ListChangeOperation.update:
        op = ListChangeOperation.update;
        break;
    }
    state.change(item, index, op);
  }
}
