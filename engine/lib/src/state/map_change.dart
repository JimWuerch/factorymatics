import 'package:engine/engine.dart';

class MapChange<K, V> extends Change {
  MapState<K, V?> state;
  K key;
  V? newValue;
  V? oldValue;
  late bool existed;
  late bool remove;

  // ignore: prefer_initializing_formals
  MapChange.add(this.state, this.key, V value) : newValue = value {
    remove = false;
    oldValue = state[key];
    existed = state.containsKey(key);
    state.game.changeStack.add(this);
  }

  MapChange.remove(this.state, this.key) {
    newValue = null;
    remove = true;
    oldValue = state[key];
    existed = true;
    state.game.changeStack.add(this);
  }

  @override
  void execute() {
    state.change(key, newValue, remove);
  }

  @override
  void undo() {
    state.change(key, oldValue, !existed);
  }
}
