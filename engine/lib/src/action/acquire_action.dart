import 'package:engine/engine.dart';

class AcquireAction extends Action {
  ResourceType resourceType;

  AcquireAction(Player player, this.resourceType) : super(ActionType.acquire, player);
}

class RequestAcquireAction extends Action {
  RequestAcquireAction(Player player) : super(ActionType.requestAcquire, player);
}

class MysteryMeatAction extends Action {
  MysteryMeatAction(Player player) : super(ActionType.mysteryMeat, player);
}

class RequestMysteryMeatAction extends Action {
  RequestMysteryMeatAction(Player player) : super(ActionType.requestMysteryMeat, player);
}
