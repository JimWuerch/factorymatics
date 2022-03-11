import 'package:engine/engine.dart';

enum TriggerType { store, acquire, construct, convert, purchased, constructLevel, constructFromStore }

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

  @override
  String toString() {
    return 'Store';
  }
}

class AcquireTrigger extends Trigger {
  final ResourceType resourceType;

  AcquireTrigger(this.resourceType) : super(TriggerType.acquire);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is AcquireAction) {
      return action?.acquiredResource == resourceType;
    }
    return false;
  }

  @override
  String toString() {
    return 'Acquire ${resourceType.name}';
  }
}

class ConstructTrigger extends Trigger {
  final ResourceType resourceType;

  ConstructTrigger(this.resourceType) : super(TriggerType.construct);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is ConstructAction) {
      return action.part.resource == resourceType || action.part.resource == ResourceType.any;
    }
    return false;
  }

  @override
  String toString() {
    return 'Construct ${resourceType.name}';
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

  @override
  String toString() {
    return 'Construct level ${level + 1}';
  }
}

class ConstructFromStoreTrigger extends Trigger {
  ConstructFromStoreTrigger() : super(TriggerType.constructFromStore);

  @override
  bool isTriggeredBy(GameAction action) {
    if (action is ConstructAction) {
      return action.fromStorage;
    }
    return false;
  }

  @override
  String toString() {
    return 'Construct from storage';
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

  @override
  String toString() {
    return 'Convert ${resourceType.name}';
  }
}
