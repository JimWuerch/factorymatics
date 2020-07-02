import 'package:engine/engine.dart';

export 'acquire_action.dart';

enum ActionType {
  store,
  construct,
  acquire,
  scavenge,
  convert,
  mysteryMeat,
  requestAcquire,
  requestConvert,
  requestMysteryMeat
}

abstract class Action {
  final ActionType actionType;
  final Player player;

  Action(this.actionType, this.player);
}
