import 'package:engine/engine.dart';

class AcquireAction extends GameAction {
  final int index;
  ResourceType acquiredResource; // set by the engine after processing

  AcquireAction(String player, this.index, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.acquire;

  @override
  bool matches(GameAction action) {
    // we match all AcquireActions
    return action is AcquireAction;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['index'] = index;
    return ret;
  }

  AcquireAction.fromJson(Game game, Map<String, dynamic> json)
      : index = json['index'] as int,
        super.fromJson(game, json);
}

class RequestAcquireAction extends GameAction {
  RequestAcquireAction(String player, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.requestAcquire;

  @override
  bool matches(GameAction action) {
    // we match all RequestAcquireAction
    return action is RequestAcquireAction;
  }

  RequestAcquireAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}

class MysteryMeatAction extends GameAction {
  MysteryMeatAction(String player, Product producedBy) : super(player, producedBy);

  // not sent over the wire
  ResourceType resource;

  @override
  ActionType get actionType => ActionType.mysteryMeat;

  @override
  bool matches(GameAction action) {
    // we match all MysteryMeatActions
    return action is MysteryMeatAction;
  }

  MysteryMeatAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}
