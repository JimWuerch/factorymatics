import 'package:engine/engine.dart';
import 'package:engine/src/action/game_mode_action.dart';

enum ValidateResponseCode { ok, notAllowed, noStorage, cantAfford, partNotForSale, unknownAction, outOfTurn }

enum TurnState {
  notStarted, // waiting for start turn action
  started, // waiting for SelectActionAction
  actionSelected, // received SelectActionAction
  selectedActionCompleted, // ready to handle triggered actions
  ended, // received end turn action
}

class Turn {
  final Game game;
  final PlayerData player;
  final GameStateVar<TurnState> turnState;
  final GameStateVar<ActionType> selectedAction;
  // bool get isActionSelected => selectedAction.value != null;
  // GameStateVar<bool> selectedActionCompleted;
  // bool get isSelectedActionCompleted => selectedActionCompleted.value;
  final ChangeStack changeStack;
  final List<GameAction> actions;
  final List<GameAction> availableActions;
  bool isGameEndTriggered;

  Turn(this.game, this.player)
      : changeStack = ChangeStack(),
        actions = <GameAction>[],
        availableActions = <GameAction>[],
        turnState = GameStateVar(game, 'turnState', TurnState.notStarted),
        selectedAction = GameStateVar(game, 'selectedAction', null),
        // selectedActionCompleted = GameStateVar(game, 'selectedActionCompleted', false),
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
        turnState = GameStateVar(game, 'turnState', TurnState.notStarted),
        selectedAction = GameStateVar(game, 'selectedAction', null),
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

  List<GameAction> getAvailableActions() {
    var ret = <GameAction>[];

    if (turnState.value == TurnState.ended) {
      return ret;
    }

    if (turnState.value == TurnState.notStarted) {
      ret.add(GameModeAction(player.id, GameModeType.startTurn));
      return ret;
    }

    if (turnState.value == TurnState.started) {
      // if we haven't selected an action yet, require that first
      if (player.hasPartStorageSpace) {
        ret.add(SelectActionAction(player.id, ActionType.store));
      }
      if (player.hasResourceStorageSpace) {
        ret.add(SelectActionAction(player.id, ActionType.acquire));
      }
      ret.add(SelectActionAction(player.id, ActionType.construct));
      ret.add(SelectActionAction(player.id, ActionType.search));
      return ret;
    }

    // converter actions can always be done at this point
    for (var part in player.parts[PartType.converter]) {
      if (!part.activated.value && part.ready.value) {
        for (var product in part.products) {
          ret.add(product.produce(game, player.id));
        }
      }
    }

    // did we do the action we selected yet?
    if (turnState.value == TurnState.actionSelected) {
      _addAllAvailableActions(ret, SelectActionAction(player.id, selectedAction.value));
      return ret;
    }

    if (turnState.value == TurnState.selectedActionCompleted) {
      // we know an action has been selected and completed, so now we can add all
      // the actions that triggered parts produce

      // allowed to end the turn now
      ret.add(GameModeAction(player.id, GameModeType.endTurn));

      // store actions
      for (var part in player.parts[PartType.storage]) {
        if (!part.activated.value && part.ready.value) {
          for (var product in part.products) {
            _addAllAvailableActions(ret, product.produce(game, player.id));
          }
        }
      }
    }

    return ret;
  }

  void _addAllAvailableActions(List<GameAction> actions, GameAction action) {
    if (action is SelectActionAction) {
      switch (action.selectedAction) {
        case ActionType.store:
          // can store any part for sale
          for (var i = 0; i < 3; ++i) {
            for (var part in game.saleParts[i]) {
              actions.add(StoreAction(player.id, part));
            }
          }
          break;

        case ActionType.acquire:
          actions.add(AcquireAction(player.id, -1));
          break;

        case ActionType.construct:
          // add all buildings we can currently afford
          for (var i = 0; i < 3; ++i) {
            for (var part in game.saleParts[i]) {
              if (player.canAfford(part)) {
                actions.add(StoreAction(player.id, part));
              }
            }
          }
          for (var part in player.savedParts) {
            if (player.canAfford(part)) {
              actions.add(StoreAction(player.id, part));
            }
          }
          break;

        default:
          break;
      }
    } else if (action is MysteryMeatAction) {
      actions.add(MysteryMeatAction(player.id));
    } else if (action is AcquireAction) {
      actions.add(AcquireAction(player.id, -1));
    }
  }

  void startTurn() {
    game.changeStack = changeStack;
    player.resetPartActivations();
    changeStack.clear();
  }

  void endTurn() {
    changeStack.clear();
    isGameEndTriggered = player.isGameEnded;
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
        if (!isDuringSearch && !game.isForSale(a.part)) {
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
  ValidateResponseCode isAvailableAction(GameAction action) {
    for (var a in availableActions) {
      if (a.matches(action)) break;
    }
    // if we got here, the action wasn't in the available list
    return ValidateResponseCode.notAllowed;
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

    if (game.isForSale(action.part) || game.isInDeck(action.part)) {
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
    changeStack.group();

    player.removeResource(action.source);
    player.storeResource(action.destination);

    changeStack.commit();
    return ret;
  }

  ValidateResponseCode _doDoubleConvert(DoubleConvertAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.storeResource(action.source);

    changeStack.commit();
    return ret;
  }

  ValidateResponseCode _doMysteryMeat(MysteryMeatAction action) {
    var ret = ValidateResponseCode.ok;

    player.storeResource(action.resource);

    return ret;
  }

  ValidateResponseCode _doVp(VpAction action) {
    var ret = ValidateResponseCode.ok;

    player.giveVpChit();

    return ret;
  }
}
