part of undo;

abstract class Change {
  Change();

  factory Change.property(Object oldValue, void Function() execute, void Function(Object oldValue) undo) {
    return _PropertyChange(oldValue, execute, undo);
  }

  factory Change.inline(void Function() execute, void Function() undo) {
    return _InlineChange(execute, undo);
  }

  String label;

  void execute();

  void undo();

  @override
  String toString() {
    return label;
  }
}

abstract class ChangeGroupBase {
  final List<_ChangeGroup> _openGroups;
  bool get isGrouping => _openGroups.isNotEmpty;

  ChangeGroupBase() : _openGroups = <_ChangeGroup>[];

  void add(Change change, {String label}) {
    if (isGrouping) {
      _openGroups.last.add(change, label: label);
    } else {
      _add(change, label: label);
    }
  }

  void _add(Change change, {String label, bool doExecute});

  void clear();

  void group({String label}) {
    _openGroups.add(_ChangeGroup()..label = label);
  }

  void commit() {
    if (isGrouping) {
      var last = _openGroups.removeLast();
      if (isGrouping) {
        _openGroups.last._add(last, label: last.label, doExecute: false);
      } else {
        _add(last, label: last.label, doExecute: false);
      }
    }
  }

  void discard() {
    if (isGrouping) {
      _openGroups.last.undo();
      _openGroups.removeLast();
    }
  }

  void undo();
}

class _PropertyChange extends Change {
  final Object _oldValue;
  final Function _execute;
  final Function _undo;

  _PropertyChange(this._oldValue, this._execute(), this._undo(Object oldValue));

  @override
  void execute() {
    _execute();
  }

  @override
  void undo() {
    _undo(_oldValue);
  }
}

class _InlineChange extends Change {
  final Function _execute;
  final Function _undo;

  _InlineChange(this._execute(), this._undo());

  @override
  void execute() {
    _execute();
  }

  @override
  void undo() {
    _undo();
  }
}

class _ChangeGroup extends ChangeGroupBase implements Change {
  @override
  String label;

  final List<Change> _changes = [];

  @override
  void _add(Change change, {String label, bool doExecute = true}) {
    if (label != null) {
      change.label = label;
    }
    _changes.add(change);
    if (doExecute) {
      change.execute();
    }
  }

  @override
  void clear() {
    _changes.clear();
  }

  @override
  void execute() {
    for (var c in _changes) {
      c.execute();
    }
    //_changes.forEach((c) => c.execute());
  }

  @override
  void undo() {
    for (var c in _changes.reversed) {
      c.undo();
    }
    //_changes.reversed.forEach((c) => c.undo());
  }
}
