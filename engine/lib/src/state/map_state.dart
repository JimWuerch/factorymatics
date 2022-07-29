import 'package:engine/engine.dart';

import 'map_change.dart';

class MapState<K, V> extends GameStateBase {
  final Map<K, V> _map;
  Map<K, V> get getMap => Map<K, V>.unmodifiable(_map);

  MapState(Game game, String label, {StateVarCallback? onChanged, Object? onChangedParam, Map<K, V>? starting})
      : _map = <K, V>{},
        super(game, label, onChanged, onChangedParam) {
    if (starting != null) {
      _map.addAll(starting);
    }
  }

  MapState.fromMap(Game game, String label, Map<K, V> map, {StateVarCallback? onChanged, Object? onChangedParam})
      : _map = map,
        super(game, label, onChanged, onChangedParam);

  void operator []=(K key, V value) {
    MapChange<K, V>.add(this, key, value);
    // if (_map.containsKey(key)) {
    //   var oldValue = _map[key];
    //   if (oldValue != value) {
    //     MapChange<K, V>.add(this, key, value);
    //   }
    // } else {
    //   MapChange<K, V>.add(this, key, value);
    // }
  }

  V? operator [](K key) => _map[key];
  V? getValue(K key) => _map[key];

  V? remove(K key) {
    if (!_map.containsKey(key)) return null;
    var old = _map[key];
    MapChange<K, V>.remove(this, key);
    return old;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void clear() {
    for (var key in _map.keys.toList()) {
      remove(key);
    }
  }

  /// Reset the map without using the ChangeList
  void reinitialize() {
    _map.clear();
  }

  Iterable<V> get values => _map.values;

  int get length => _map.length;

  bool get isEmpty => _map.isEmpty;

  // ignore: avoid_positional_boolean_parameters
  void change(K key, V value, bool remove) {
    if (remove) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }
    if (onChanged != null) onChanged!(this, onChangedParam);
  }
}
