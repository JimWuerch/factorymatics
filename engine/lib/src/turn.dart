import 'package:engine/engine.dart';

enum ValidateResponseCode { ok, notAllowed, noStorage, cantAfford, partNotForSale, unknownAction, outOfTurn }

class Turn {
  final Game game;
  final PlayerData player;
  GameStateVar<ActionType> selectedAction;
  bool get isActionSelected => selectedAction.value != null;
  final ChangeStack changeStack;
  final List<GameAction> actions;
  final List<GameAction> availableActions;
  bool isGameEndTriggered;

  Turn(this.game, this.player)
      : changeStack = ChangeStack(),
        actions = <GameAction>[],
        availableActions = <GameAction>[],
        selectedAction = GameStateVar(game, 'selectedAction', null),
        isGameEndTriggered = false {
    // do stuff
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{
      'player': player.id,
      'actions': actions.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
    };

    return ret;
  }

  Turn._fromJsonHelper(this.game, this.player, List<GameAction> actionList)
      : changeStack = ChangeStack(),
        actions = <GameAction>[],
        availableActions = <GameAction>[],
        isGameEndTriggered = false {
    // replay the turn
    for (var action in actionList) {
      processAction(action);
    }
  }

  factory Turn.fromJson(Game game, Map<String, dynamic> json) {
    var player = game.getPlayerFromId(json['player'] as String);
    var item = json['players'] as List<dynamic>;
    var actions = item.map<GameAction>((dynamic json) => actionFromJson(game, json as Map<String, dynamic>)).toList();

    return Turn._fromJsonHelper(game, player, actions);
  }

  void startTurn() {
    game.changeStack = changeStack;
    player.resetPartActivations();
    changeStack.clear();
  }

  void endTurn() {
    isGameEndTriggered = player.isGameEnded;
    game.refillMarket();
    game.changeStack = null;
    game.endTurn();
  }

  ValidateResponseCode verifyAction(GameAction action, {bool isDuringSearch = false}) {
    // first make sure it's something that the game state allows
    if (action.owner != player.id) {
      return ValidateResponseCode.outOfTurn;
    }
    var code = isAvailableAction(action);
    if (code != ValidateResponseCode.ok) return code;

    // now make sure the player can do the action
    switch (action.actionType) {
      case ActionType.store:
        //case ActionType.requestStore:
        return player.hasPartStorageSpace ? ValidateResponseCode.ok : ValidateResponseCode.noStorage;

      case ActionType.construct:
        var a = action as ConstructAction;
        if (!isDuringSearch && !isPartForSale(a.part)) {
          return ValidateResponseCode.partNotForSale;
        }
        if (isDuringSearch && !game.isInDeck(a.part)) {
          return ValidateResponseCode.partNotForSale;
        }

        return player.canAfford(a.part) ? ValidateResponseCode.ok : ValidateResponseCode.cantAfford;
      // case ActionType.requestConstruct:
      //   var a = action as ConstructAction;
      //   return isPartForSale(a.part) && player.canAfford(a.part);

      case ActionType.acquire:
        //case ActionType.requestAcquire:
        return player.hasResourceStorageSpace ? ValidateResponseCode.ok : ValidateResponseCode.noStorage;

      case ActionType.search:
        return verifyAction((action as SearchAction).action);
      // case ActionType.requestSearch:
      //   return verifyAction((action as RequestSearchAction).action);

      case ActionType.convert:
        return player.hasResource((action as ConvertAction).source)
            ? ValidateResponseCode.ok
            : ValidateResponseCode.cantAfford;
      // case ActionType.requestConvert:
      //   return player.hasResource((action as RequestConvertAction).source);

      case ActionType.doubleConvert:
        if (!player.hasResource((action as DoubleConvertAction).source)) return ValidateResponseCode.cantAfford;
        return player.hasResourceStorageSpace ? ValidateResponseCode.ok : ValidateResponseCode.noStorage;
      // case ActionType.requestDoubleConvert:
      //   return player.hasResource((action as DoubleConvertAction).source) && player.hasResourceStorageSpace;

      case ActionType.mysteryMeat:
        // case ActionType.requestMysteryMeat:
        return player.hasResourceStorageSpace ? ValidateResponseCode.ok : ValidateResponseCode.noStorage;

      case ActionType.vp:
        // case ActionType.requestVp:
        return ValidateResponseCode.ok;

      default:
        return ValidateResponseCode.unknownAction;
    }
  }

  // check to see if the player is even allowed to do the action
  ValidateResponseCode isAvailableAction(GameAction action, {bool isDuringSearch = false}) {
    if (!isActionSelected) {
      // can only do these as a main action
      if (action.actionType != ActionType.store &&
          action.actionType != ActionType.acquire &&
          action.actionType != ActionType.construct &&
          action.actionType != ActionType.search) {
        return ValidateResponseCode.notAllowed;
      }
    } else {
      for (var a in availableActions) {
        if (a.matches(action)) break;
      }
      // if we got here, the action wasn't in the available list
      return ValidateResponseCode.notAllowed;
    }
/*
    switch (action.actionType) {
      case ActionType.store:
        if (isActionSelected && !isDuringSearch) {
          return ValidateResponseCode.notAllowed;
        } else {
          return ValidateResponseCode.ok;
        }
      case ActionType.construct:
        // TODO: Handle this case.
        break;
      case ActionType.acquire:
        // TODO: Handle this case.
        break;
      case ActionType.search:
        // TODO: Handle this case.
        break;
      case ActionType.convert:
        // TODO: Handle this case.
        break;
      case ActionType.doubleConvert:
        // TODO: Handle this case.
        break;
      case ActionType.mysteryMeat:
        // TODO: Handle this case.
        break;
      case ActionType.vp:
        // TODO: Handle this case.
        break;
      default:
        return ValidateResponseCode.unknownAction;
    }
    */
    return ValidateResponseCode.ok;
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

  ValidateResponseCode selectAction(GameAction action) {
    selectedAction.value = action.actionType;

    switch (selectedAction.value) {
      case ActionType.store:
        _selectedStoreAction(action as StoreAction);
        break;

      case ActionType.acquire:
        _selectedAcquireAction(action as AcquireAction);
        break;

      case ActionType.construct:
        _selectedConstructAction(action as ConstructAction);
        break;

      case ActionType.search:
        _selectedSearchAction(action as SearchAction);
        break;

      default:
        return ValidateResponseCode.unknownAction;
    }

    return ValidateResponseCode.ok;
  }

  void _selectedStoreAction(GameAction action) {}

  void _selectedAcquireAction(GameAction action) {}

  void _selectedConstructAction(GameAction action) {}

  void _selectedSearchAction(GameAction action) {}

  ValidateResponseCode processAction(GameAction action) {
    var ret = verifyAction(action);
    if (ret != ValidateResponseCode.ok) {
      return ret;
    }

    switch (action.actionType) {
      case ActionType.store:
        ret = _doStore(action as StoreAction);
        break;
      case ActionType.construct:
        ret = _doConstruct(action as ConstructAction);
        break;
      case ActionType.acquire:
        ret = _doAcquire(action as AcquireAction);
        break;
      case ActionType.search:
        ret = _doSearch(action as SearchAction);
        break;
      case ActionType.convert:
        ret = _doConvert(action as ConvertAction);
        break;
      case ActionType.doubleConvert:
        ret = _doDoubleConvert(action as DoubleConvertAction);
        break;
      case ActionType.mysteryMeat:
        ret = _doMysteryMeat(action as MysteryMeatAction);
        break;
      case ActionType.vp:
        ret = _doVp(action as VpAction);
        break;
      default:
        ret = ValidateResponseCode.unknownAction;
    }

    return ret;
  }

  void _doTriggers(GameAction gameAction, PartType partType) {
    for (var part in player.parts[partType]) {
      for (var trigger in part.triggers) {
        if (trigger.isTriggeredBy(gameAction)) {
          part.activated.value = true;
          for (var product in part.products) {
            availableActions.add(product.produce(game, player.id));
          }
        }
      }
    }
  }

  void _markActionExecuted(GameAction action) {
    for (var index = 0; index < availableActions.length; ++index) {
      if (availableActions[index].matches(action)) {
        availableActions.removeAt(index);
        break;
      }
    }
  }

  ValidateResponseCode _doStore(StoreAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    game.removePart(action.part);
    player.savePart(action.part);

    _markActionExecuted(action);
    _doTriggers(action, PartType.construct);

    changeStack.commit();
    return ret;
  }

  ValidateResponseCode _doConstruct(ConstructAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    if (isPartForSale(action.part) || game.isInDeck(action.part)) {
      game.removePart(action.part);
    } else if (player.isInStorage(action.part)) {
      player.unsavePart(action.part);
    } else {
      changeStack.discard();
      return ValidateResponseCode.partNotForSale;
    }

    player.buyPart(action.part, action.payment);

    changeStack.commit();
    return ret;
  }

  ValidateResponseCode _doAcquire(AcquireAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.storeResource(game.acquireResource(action.index));

    changeStack.commit();
    // since we revealed info, no more undo
    changeStack.clear();
    return ret;
  }

  ValidateResponseCode _doSearch(SearchAction action) {
    var ret = ValidateResponseCode.ok;

    return ret;
  }

  ValidateResponseCode _doConvert(ConvertAction action) {
    var ret = ValidateResponseCode.ok;

    return ret;
  }

  ValidateResponseCode _doDoubleConvert(DoubleConvertAction action) {
    var ret = ValidateResponseCode.ok;

    return ret;
  }

  ValidateResponseCode _doMysteryMeat(MysteryMeatAction action) {
    var ret = ValidateResponseCode.ok;

    return ret;
  }

  ValidateResponseCode _doVp(VpAction action) {
    var ret = ValidateResponseCode.ok;

    return ret;
  }
}
