import 'package:engine/engine.dart';
import 'package:engine/src/undo/undo.dart' as undo;

export 'default_value_map_state.dart';
export 'list_state.dart';
export 'map_state.dart';

typedef StateVarCallback = void Function(GameStateVar);

abstract class GameState {
  String get label;
  StateVarCallback onChanged;
  Game get game;
}

abstract class GameStateBase implements GameState {
  final String _label;
  final Game _game;

  @override
  StateVarCallback onChanged;

  GameStateBase(this._game, this._label, this.onChanged);

  @override
  Game get game => _game;

  @override
  String get label => _label;
}

class GameStateVar<T> extends GameStateBase {
  T _value;
  final ChangeStack _changeStack; // used for unit testing only

  GameStateVar(Game game, String name, T startValue, {StateVarCallback onChanged, ChangeStack changeStack})
      : _value = startValue,
        _changeStack = changeStack,
        super(game, name, onChanged);

  T get value => _value;
  set value(T newValue) {
    if (_changeStack == null) {
      game.changeStack.add(undo.Change.property(_value, () => _change(newValue), (oldValue) => _change(oldValue as T)),
          label: label);
    } else {
      _changeStack.add(undo.Change.property(_value, () => _change(newValue), (oldValue) => _change(oldValue as T)),
          label: label);
    }
  }

  // ignore: use_setters_to_change_properties
  void reinitialize(T value) {
    // using this skips the changestack
    _value = value;
  }

  void _change(T newValue) {
    log.fine('Change $label from $_value to $newValue');
    _value = newValue;
    if (onChanged != null) onChanged(this);
  }

  @override
  String toString() {
    return _value.toString();
  }
}
