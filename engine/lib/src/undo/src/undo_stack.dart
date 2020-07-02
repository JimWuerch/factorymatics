part of undo;

class ChangeStack extends ChangeGroupBase {
  final _streamController = StreamController<ChangeStack>.broadcast();
  Stream<ChangeStack> get stream => _streamController.stream.asBroadcastStream();

  final Queue<Change> _undos = ListQueue();
  final Queue<Change> _redos = ListQueue();

  int max;

  bool get canRedo => _redos.isNotEmpty && !isGrouping;
  bool get canUndo => _undos.isNotEmpty && !isGrouping;

  String get redoLabel => canRedo ? _redos.first.label : '';
  String get undoLabel => canUndo ? _undos.last.label : '';

  ChangeStack({this.max}) {
    _streamController.add(this);
  }

  @override
  void _add(Change change, {String label, bool doExecute = true}) {
    if (label != null) {
      change.label = label;
    }

    if (doExecute) {
      change.execute();
    }

    _undos.addLast(change);
    _redos.clear();

    if (max != null && _undos.length > max) {
      _undos.removeFirst();
    }

    _streamController.add(this);
  }

  // @override
  // void _add(Change change, {String label}) {
  //   _doAdd(change, true);
  // }

  @override
  void clear() {
    if (isGrouping) {
      _openGroup.clear();
      _openGroup = null;
    }
    _undos.clear();
    _redos.clear();
    _streamController.add(null);
  }

  void redo() {
    if (canRedo) {
      var change = _redos.removeFirst();
      change.execute();
      _undos.addLast(change);
      _streamController.add(this);
    }
  }

  @override
  void undo() {
    if (canUndo) {
      var change = _undos.removeLast();
      change.undo();
      _redos.addFirst(change);
      _streamController.add(this);
    }
  }

  void dispose() {
    _streamController.close();
  }

  void merge(ChangeStack stack) {
    if (max != null) {
      throw UnimplementedError('Cannot merge if max is set');
    }

    _undos.addAll(stack._undos);
    _redos.clear();
  }
}
