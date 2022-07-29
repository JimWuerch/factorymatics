import 'package:engine/engine.dart';

// Extends MapState and allows a default value if a key is missing during a lookup
// this works even for cases where V can be null
class DefaultValueMapState<K, V> extends MapState<K, V> {
  final V defaultValue;
  DefaultValueMapState(Game game, String label, this.defaultValue, {StateVarCallback? onChanged, Map<K, V>? starting})
      : super(game, label, onChanged: onChanged, starting: starting);

  V? operator [](K key) {
    if (containsKey(key)) {
      return getValue(key);
    } else {
      return defaultValue;
    }
  }
}
