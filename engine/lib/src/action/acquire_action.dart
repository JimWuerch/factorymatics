import 'package:engine/engine.dart';

class AcquireAction extends GameAction {
  ResourceType resourceType;

  AcquireAction(String player, this.resourceType) : super(player);

  @override
  ActionType get actionType => ActionType.acquire;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['r'] = ResourceType.values.indexOf(resourceType);
    return ret;
  }

  AcquireAction.fromJson(Game game, Map<String, dynamic> json)
      : resourceType = ResourceType.values[json['r'] as int],
        super.fromJson(game, json);
}

class RequestAcquireAction extends GameAction {
  RequestAcquireAction(String player) : super(player);

  @override
  ActionType get actionType => ActionType.requestAcquire;

  RequestAcquireAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}

class MysteryMeatAction extends GameAction {
  MysteryMeatAction(String player) : super(player);

  @override
  ActionType get actionType => ActionType.mysteryMeat;

  MysteryMeatAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}

class RequestMysteryMeatAction extends GameAction {
  RequestMysteryMeatAction(String player) : super(player);

  @override
  ActionType get actionType => ActionType.requestMysteryMeat;

  RequestMysteryMeatAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}
