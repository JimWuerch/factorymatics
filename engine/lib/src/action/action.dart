import 'package:engine/engine.dart';

export 'acquire_action.dart';

enum ActionType {
  store,
  construct,
  acquire,
  scavenge,
  convert,
  doubleConvert,
  mysteryMeat,
  vp,
  requestStore,
  requestConstruct,
  requestAcquire,
  requestConvert,
  requestDoubleConvert,
  requestMysteryMeat,
  requestVp,
}

abstract class Action {
  final ActionType actionType;
  final Player player;

  Action(this.actionType, this.player);
}
