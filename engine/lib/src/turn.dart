import 'package:engine/engine.dart';

class Turn {
  Game game;
  PlayerData player;
  ActionType selectedAction;
  bool get isActionSelected => selectedAction != null;

  Turn(this.game, this.player) {
    // do stuff
  }

  void startTurn() {
    player.resetPartActivations();
  }

  bool verifyAction(GameAction action) {
    if (!isAvailableAction(action)) return false;

    switch (action.actionType) {
      case ActionType.store:
      case ActionType.requestStore:
        return player.hasPartStorageSpace;

      case ActionType.construct:
        var a = action as ConstructAction;
        return isPartForSale(a.part) && player.canAfford(a.part);
      case ActionType.requestConstruct:
        var a = action as ConstructAction;
        return isPartForSale(a.part) && player.canAfford(a.part);

      case ActionType.acquire:
      case ActionType.requestAcquire:
        return player.hasResourceStorageSpace;

      case ActionType.scavenge:
        return verifyAction((action as ScavengeAction).action);
      case ActionType.requestScavenge:
        return verifyAction((action as RequestScavengeAction).action);

      case ActionType.convert:
        return player.hasResource((action as ConvertAction).source);
      case ActionType.requestConvert:
        return player.hasResource((action as RequestConvertAction).source);

      case ActionType.doubleConvert:
        return player.hasResource((action as DoubleConvertAction).source);
      case ActionType.requestDoubleConvert:
        return player.hasResource((action as DoubleConvertAction).source);

      case ActionType.mysteryMeat:
      case ActionType.requestMysteryMeat:
        return true;

      case ActionType.vp:
      case ActionType.requestVp:
        return true;

      default:
        throw InvalidOperationError('Unknown action');
    }
  }

  bool isAvailableAction(GameAction action) {
    return false;
  }

  bool isPartForSale(Part part) {
    switch (part.level) {
      case 1:
        return -1 != game.level1Sale.indexOf(part);
      case 2:
        return -1 != game.level2Sale.indexOf(part);
      case 3:
        return -1 != game.level3Sale.indexOf(part);
      default:
        throw InvalidOperationError('Check for invalid part');
    }
  }

  void selectAction(GameAction action) {
    selectedAction = action.actionType;

    switch (selectedAction) {
      case ActionType.store:
        _selectedStoreAction(action as StoreAction);
        break;

      case ActionType.acquire:
        _selectedAcquireAction(action as AcquireAction);
        break;

      case ActionType.construct:
        _selectedConstructAction(action as ConstructAction);
        break;

      case ActionType.scavenge:
        _selectedScavengeAction(action as ScavengeAction);
        break;

      default:
        throw InvalidOperationError('Invalid selected action ${selectedAction.toString()}');
    }

    return;
  }

  void _selectedStoreAction(GameAction action) {}

  void _selectedAcquireAction(GameAction action) {}

  void _selectedConstructAction(GameAction action) {}

  void _selectedScavengeAction(GameAction action) {}

  void processAction(GameAction action) {}
}
