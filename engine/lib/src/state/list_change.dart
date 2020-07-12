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
    execute();
  }

  ListChange.remove(this.state, this.index)
      : item = state[index],
        operation = ListChangeOperation.remove,
        oldItem = null {
    execute();
  }

  ListChange.update(this.state, this.item, this.index)
      : operation = ListChangeOperation.update,
        oldItem = state[index] {
    execute();
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
