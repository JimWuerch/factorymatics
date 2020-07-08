import 'package:engine/engine.dart';
import 'package:engine/src/action/construct_action.dart';
import 'package:engine/src/action/convert_action.dart';

enum TriggerType { store, acquire, construct, convert, purchased, constructLevel }

abstract class Trigger {
  final TriggerType triggerType;

  Trigger(this.triggerType);

  bool isTriggeredBy(GameAction action);
}

class StoreTrigger extends Trigger {
  StoreTrigger() : super(TriggerType.store);

  @override
  bool isTriggeredBy(GameAction action) {
    return action.actionType == ActionType.store;
  }
}

class AcquireTrigger extends Trigger {
  final ResourceType resourceType;

  AcquireTrigger(this.resourceType) : super(TriggerType.acquire);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is AcquireAction) {
      return action.resourceType == resourceType;
    }
    return false;
  }
}

class ConstructTrigger extends Trigger {
  final ResourceType resourceType;

  ConstructTrigger(this.resourceType) : super(TriggerType.construct);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is ConstructAction) {
      return action.part.resource == resourceType;
    }
    return false;
  }
}

class ConstructLevelTrigger extends Trigger {
  final int level;

  ConstructLevelTrigger(this.level) : super(TriggerType.constructLevel);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is ConstructAction) {
      return action.part.level == level;
    }
    return false;
  }
}

class ConvertTrigger extends Trigger {
  final ResourceType resourceType;

  ConvertTrigger(this.resourceType) : super(TriggerType.convert);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is ConvertAction) {
      return action.source == resourceType;
    }
    return false;
  }
}
