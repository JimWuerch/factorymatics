import 'package:engine/engine.dart';

enum ListChangeOperation { add, remove, update }

class ListChange<T> extends Change {
  final ListState<T> state;
  final T item;
  final int index;
  final ListChangeOperation operation;

  ListChange.add(this.state, this.item, this.index) : operation = ListChangeOperation.add {
    execute();
  }

  ListChange.remove(this.state, this.index)
      : item = state[index],
        operation = ListChangeOperation.remove {
    execute();
  }

  ListChange.update(this.state, this.item, this.index) : operation = ListChangeOperation.update {
    execute();
  }

  @override
  void execute() {
    // TODO: implement execute
  }

  @override
  void undo() {
    // TODO: implement undo
  }
}
