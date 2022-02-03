import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:tuple/tuple.dart';

enum ValidateResponseCode { ok, notAllowed, noStorage, cantAfford, partNotForSale, unknownAction, outOfTurn }

enum TurnState {
  notStarted, // waiting for start turn action
  started, // waiting for SelectActionAction
  actionSelected, // received SelectActionAction
  searchSelected, // if the selectedAction is search, this state is waiting for the deck choice
  selectedActionCompleted, // ready to handle triggered actions
  acquireRequested, // acquire request as result of product triggered
  ended, // received end turn action
  gameEnded, // end of game detected, no more allowed actions
}

class Turn {
  final Game game;
  final PlayerData player;
  final GameStateVar<TurnState> turnState;
  final GameStateVar<ActionType> selectedAction;
  final ChangeStack changeStack;
  final Map<ResourceType, GameStateVar<int>> convertedResources;
  bool isGameEndTriggered;
  List<Part> searchedParts;

  Turn(this.game, this.player)
      : changeStack = ChangeStack(),
        turnState = GameStateVar(game, 'turnState', TurnState.notStarted),
        selectedAction = GameStateVar(game, 'selectedAction', null),
        convertedResources = <ResourceType, GameStateVar<int>>{},
        isGameEndTriggered = false {
    PlayerData.initResourceMap(game, convertedResources, 'cRes');
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{
      //'player': player.id,
      'state': TurnState.values.indexOf(turnState.value),
    };
    if (selectedAction.value != null) {
      ret['selectedAction'] = ActionType.values.indexOf(selectedAction.value);
    }
    if (searchedParts != null) {
      var p = <String>[];
      for (var part in searchedParts) {
        p.add(part.id);
      }
      ret['searchedParts'] = p;
    }
    var convertedResString = resourceMapStateToString(convertedResources);
    if (convertedResString.isNotEmpty) {
      ret['convRes'] = convertedResString;
    }

    return ret;
  }

  Turn._fromJsonHelper(this.game, this.player, TurnState state, ActionType selected, this.searchedParts, this.convertedResources)
      : changeStack = ChangeStack(),
        turnState = GameStateVar(game, 'turnState', state),
        selectedAction = GameStateVar(game, 'selectedAction', selected),
        isGameEndTriggered = false {
    if (state != TurnState.notStarted) {
      game.changeStack = changeStack;
    }
  }

  factory Turn.fromJson(Game game, PlayerData player, Map<String, dynamic> json) {
    //var player = game.getPlayerFromId(json['player'] as String);
    var turnState = TurnState.values[json['state'] as int];
    ActionType selectedAction;
    if (json.containsKey('selectedAction')) {
      selectedAction = ActionType.values[json['selectedAction'] as int];
    }
    List<Part> searchedParts;
    if (json.containsKey('searchedParts')) {
      var plist = listFromJson<String>(json['searchedParts']);
      searchedParts = <Part>[];
      for (var p in plist) {
        searchedParts.add(game.allParts[p]);
      }
    }
    var res = stringToResourceMap(json['res'] as String);
    var convRes = <ResourceType, GameStateVar<int>>{};
    PlayerData.initResourceMap(game, convRes, 'cRes');
    convRes[ResourceType.heart].reinitialize(res[ResourceType.heart]);
    convRes[ResourceType.club].reinitialize(res[ResourceType.club]);
    convRes[ResourceType.spade].reinitialize(res[ResourceType.spade]);
    convRes[ResourceType.diamond].reinitialize(res[ResourceType.diamond]);

    return Turn._fromJsonHelper(game, player, turnState, selectedAction, searchedParts, convRes);
  }

  List<GameAction> getAvailableActions() {
    var ret = <GameAction>[];

    if (changeStack.canUndo) {
      ret.add(GameModeAction(player.id, GameModeType.undo));
    }

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

    // converter actions are available at this point
    for (var part in player.parts[PartType.converter]) {
      for (var product in part.products) {
        if (!product.activated.value) {
          _addAllAvailableActions(ret, part, product.produce(game, player.id));
        }
      }
    }

    // did we do the action we selected yet?
    if (turnState.value == TurnState.actionSelected) {
      _addAllAvailableActions(ret, null, SelectActionAction(player.id, selectedAction.value));
      return ret;
    }

    // we can build or store one of the parts we searched
    if (turnState.value == TurnState.searchSelected) {
      _addSearchedPartActions(ret);
    }

    if (turnState.value == TurnState.acquireRequested) {
      _addAllAvailableActions(ret, null, AcquireAction(player.id, -1, null));
      return ret;
    }

    if (turnState.value == TurnState.selectedActionCompleted) {
      // we know an action has been selected and completed, so now we can add all
      // the actions that triggered parts produce

      // allowed to end the turn now
      ret.add(GameModeAction(player.id, GameModeType.endTurn));

      // triggered actions
      for (var partList in player.parts.values) {
        for (var part in partList) {
          if (part.partType == PartType.storage || part.partType == PartType.acquire || part.partType == PartType.construct) {
            if (part.ready.value) {
              for (var product in part.products) {
                if (!product.activated.value) {
                  if (product.productType == ProductType.aquire || product.productType == ProductType.mysteryMeat) {
                    if (!player.hasResourceStorageSpace) {
                      continue;
                    }
                  }
                  _addAllAvailableActions(ret, part, product.produce(game, player.id));
                }
              }
            }
          }
        }
      }
    }

    return ret;
  }

  void _addSearchedPartActions(List<GameAction> actions) {
    if (searchedParts == null) return;
    for (var part in searchedParts) {
      if (player.canAfford(part, player.constructFromSearchDiscount, convertedResources)) {
        actions.add(ConstructAction(player.id, part, null, null));
      }
      if (player.hasPartStorageSpace) {
        actions.add(StoreAction(player.id, part, null));
      }
    }
  }

  void _addAllAvailableActions(List<GameAction> actions, Part part, GameAction action) {
    if (action is SelectActionAction) {
      switch (action.selectedAction) {
        case ActionType.store:
          // can store any part for sale
          _addStorePartActions(actions, null);
          break;

        case ActionType.acquire:
          actions.add(AcquireAction(player.id, -1, null));
          //actions.add(RequestAcquireAction(player.id, null));
          break;

        case ActionType.construct:
          // add all buildings we can currently afford
          _addAffordablePartActions(actions, null, 0);
          break;

        case ActionType.search:
          // can search one of the 3 decks
          actions.add(SearchAction(player.id, 0));
          actions.add(SearchAction(player.id, 1));
          actions.add(SearchAction(player.id, 2));
          break;

        default:
          break;
      }
    } else if (action is MysteryMeatAction) {
      actions.add(action);
    } else if (action is AcquireAction) {
      actions.add(action);
    } else if (action is ConvertAction) {
      if (player.hasResource(action.source)) {
        actions.add(action);
      }
    } else if (action is DoubleConvertAction) {
      if (player.hasResource(action.source)) {
        actions.add(action);
      }
    } else if (action is RequestAcquireAction) {
      actions.add(action);
    }
  }

  void _addStorePartActions(List<GameAction> actions, Product producedBy) {
    if (player.hasPartStorageSpace) {
      for (var i = 0; i < 3; ++i) {
        for (var part in game.saleParts[i]) {
          actions.add(StoreAction(player.id, part, producedBy));
        }
      }
    }
  }

  HashSet<Part> getAffordableParts(int discount) {
    var items = HashSet<Part>();
    for (var i = 0; i < 3; ++i) {
      for (var part in game.saleParts[i]) {
        if (part.level == 1) discount += player.constructLevel2Discount;
        if (player.canAfford(part, discount, convertedResources)) {
          items.add(part);
        }
      }
    }
    for (var part in player.savedParts) {
      if (part.level == 1) discount += player.constructLevel2Discount;
      discount += player.constructFromStoreDiscount;
      if (player.canAfford(part, discount, convertedResources)) {
        items.add(part);
      }
    }
    return items;
  }

  void _addAffordablePartActions(List<GameAction> actions, Product producedBy, int discount) {
    var parts = getAffordableParts(discount);
    for (var part in parts) {
      actions.add(ConstructAction(player.id, part, <ResourceType>[], producedBy));
    }
  }

  void startTurn() {
    game.changeStack = changeStack;
    player.resetPartActivations();
    // converters don't rely on previous triggers, so enable them
    for (var part in player.parts[PartType.converter]) {
      if (!part.ready.value) {
        part.ready.value = true;
      }
    }
    turnState.value = TurnState.started;
    changeStack.clear();
  }

  void endTurn() {
    turnState.value = TurnState.ended;
    for (var item in convertedResources.values) {
      item.value = 0;
    }
    isGameEndTriggered = (player.partCount > 15) || (player.level3PartCount > 3);
    if (isGameEndTriggered) {
      turnState.value = TurnState.gameEnded;
    }

    changeStack.clear();
    game.changeStack = null;
    game.endTurn();
  }

/*
  ValidateResponseCode verifyAction(GameAction action) {
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
*/
  // check to see if the player is even allowed to do the action
  GameAction _isAvailableAction(GameAction action) {
    var availableActions = getAvailableActions();
    for (var a in availableActions) {
      if (a.matches(action)) return a;
    }
    // if we got here, the action wasn't in the available list
    return null;
  }

  // ValidateResponseCode selectAction(GameAction action) {
  //   selectedAction.value = action.actionType;

  //   switch (selectedAction.value) {
  //     case ActionType.store:
  //       _selectedStoreAction(action as StoreAction);
  //       break;

  //     case ActionType.acquire:
  //       _selectedAcquireAction(action as AcquireAction);
  //       break;

  //     case ActionType.construct:
  //       _selectedConstructAction(action as ConstructAction);
  //       break;

  //     case ActionType.search:
  //       _selectedSearchAction(action as SearchAction);
  //       break;

  //     default:
  //       return ValidateResponseCode.unknownAction;
  //   }

  //   return ValidateResponseCode.ok;
  // }

  // void _selectedStoreAction(GameAction action) {}

  // void _selectedAcquireAction(GameAction action) {}

  // void _selectedConstructAction(GameAction action) {}

  // void _selectedSearchAction(GameAction action) {}

  Tuple2<ValidateResponseCode, GameAction> processAction(GameAction action) {
    var matchedAction = _isAvailableAction(action);
    if (matchedAction == null) {
      return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.notAllowed, null);
    }

    // the source may not know who made the action available
    action.producedBy == matchedAction.producedBy;

    switch (action.actionType) {
      case ActionType.gameMode:
        if (action is GameModeAction) {
          if (action.mode == GameModeType.startTurn) {
            startTurn();
            return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.ok, null);
          } else if (action.mode == GameModeType.endTurn) {
            endTurn();
            return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.ok, null);
          } else if (action.mode == GameModeType.undo) {
            if (changeStack.canUndo) {
              changeStack.undo();
              return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.ok, null);
            } else {
              return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.notAllowed, null);
            }
          }
        }
        return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.notAllowed, null);
      case ActionType.selectAction:
        changeStack.group();
        var a = action as SelectActionAction;
        selectedAction.value = a.selectedAction;
        turnState.value = TurnState.actionSelected;
        changeStack.commit();
        return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.ok, null);
      case ActionType.store:
        return _doStore(action as StoreAction);
        break;
      case ActionType.construct:
        return _doConstruct(action as ConstructAction);
        break;
      case ActionType.acquire:
        return _doAcquire(action as AcquireAction);
        break;
      case ActionType.search:
        return _doSearch(action as SearchAction);
        break;
      case ActionType.convert:
        return _doConvert(action as ConvertAction);
        break;
      case ActionType.doubleConvert:
        return _doDoubleConvert(action as DoubleConvertAction);
        break;
      case ActionType.mysteryMeat:
        return _doMysteryMeat(action as MysteryMeatAction);
        break;
      case ActionType.vp:
        return _doVp(action as VpAction);
        break;
      case ActionType.requestAcquire:
        return _doRequestAcquire(action as RequestAcquireAction);
      default:
        return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.unknownAction, null);
    }
  }

  void _doTriggers(Game game, GameAction gameAction, PartType partType) {
    for (var part in player.parts[partType]) {
      if (!part.ready.value) {
        for (var trigger in part.triggers) {
          if (trigger.isTriggeredBy(gameAction)) {
            part.ready.value = true;
            _fixResourceAcquireProducts(player);
            _doTriggeredVpProducts(game, part, gameAction.owner);
          }
        }
      }
    }
  }

  // don't make the user manually trigger VP actions
  void _doTriggeredVpProducts(Game game, Part part, String playerId) {
    for (var product in part.products) {
      if (!product.activated.value && product is VpProduct) {
        _doVp((product.produce(game, playerId)) as VpAction);
      }
    }
  }

  // if any products require resource storage space,
  // disable them if the player has no space
  void _fixResourceAcquireProducts(PlayerData player) {
    if (player.hasResourceStorageSpace) return;
    for (var partList in player.parts.values) {
      for (var part in partList) {
        for (var product in part.products) {
          if (!product.activated.value && (product.productType == ProductType.aquire || product.productType == ProductType.mysteryMeat)) {
            product.activated.value = true;
          }
        }
      }
    }
  }

  // void _markActionExecuted(GameAction action) {
  //   for (var index = 0; index < availableActions.length; ++index) {
  //     if (availableActions[index].matches(action)) {
  //       availableActions.removeAt(index);
  //       break;
  //     }
  //   }
  // }

  ValidateResponseCode _doSearchCompleted(Part part) {
    if (!searchedParts.contains(part) || turnState.value != TurnState.searchSelected) {
      return ValidateResponseCode.notAllowed;
    }

    searchedParts.remove(part);
    for (var part in searchedParts) {
      game.returnPart(part);
    }

    turnState.value = TurnState.selectedActionCompleted;

    return ValidateResponseCode.ok;
  }

  Tuple2<ValidateResponseCode, GameAction> _doStore(StoreAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.savePart(action.part);

    if (turnState == TurnState.searchSelected) {
      ret = _doSearchCompleted(action.part);
      if (ValidateResponseCode.ok != ret) {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction>(ret, null);
      }
    } else {
      game.removePart(action.part);
    }

    if (action.producedBy != null) {
      action.producedBy.activated.value = true;
    }

    _doTriggers(game, action, PartType.storage);

    if (turnState.value == TurnState.actionSelected) {
      turnState.value = TurnState.selectedActionCompleted;
    }

    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doConstruct(ConstructAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    // do this first so we don't trigger ourself
    if (action.producedBy != null) {
      action.producedBy.activated.value = true;
    }
    _doTriggers(game, action, PartType.construct);

    if (turnState.value != TurnState.searchSelected) {
      if (game.isForSale(action.part) || game.isInDeck(action.part)) {
        game.removePart(action.part);
      } else if (player.isInStorage(action.part)) {
        player.unsavePart(action.part);
      } else {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.partNotForSale, null);
      }
    }

    // make player pay for the part
    player.buyPart(action.part);
    for (var resource in action.payment) {
      if (convertedResources[resource].value > 0) {
        convertedResources[resource].value--;
      } else if (player.resources[resource].value > 0) {
        player.removeResource(resource);
      } else {
        log.severe('Player ${player.id} failed to spend ${resource.name}');
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.notAllowed, null);
      }
      game.addToWell(resource);
    }

    // we can use the new part this turn
    if (action.part.partType == PartType.converter) {
      action.part.ready.value = true;
    }

    if (turnState == TurnState.searchSelected) {
      ret = _doSearchCompleted(action.part);
      if (ValidateResponseCode.ok != ret) {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction>(ret, null);
      }
    } else if (turnState.value == TurnState.actionSelected) {
      turnState.value = TurnState.selectedActionCompleted;
    }

    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doAcquire(AcquireAction action) {
    var ret = ValidateResponseCode.ok;

    if (player.hasResourceStorageSpace) {
      changeStack.group();

      action.acquiredResource = game.acquireResource(action.index);
      player.storeResource(action.acquiredResource);

      if (action.producedBy != null) {
        action.producedBy.activated.value = true;
      }

      _doTriggers(game, action, PartType.acquire);

      if (turnState.value == TurnState.actionSelected || turnState.value == TurnState.acquireRequested) {
        turnState.value = TurnState.selectedActionCompleted;
      }

      changeStack.commit();
      // since we revealed info, no more undo
      changeStack.clear();
    } else {
      ret = ValidateResponseCode.noStorage;
    }
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doSearch(SearchAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    searchedParts = <Part>[];
    var parts = <String>[];
    for (var i = 0; i < player.search; ++i) {
      var part = game.drawPart(action.level);
      searchedParts.add(part);
      parts.add(part.id);
    }

    turnState.value = TurnState.searchSelected;

    changeStack.commit();
    // we looked at cards, no more undo
    changeStack.clear();

    var result = SearchActionResult(player.id, parts);
    return Tuple2<ValidateResponseCode, GameAction>(ret, result);
  }

  Tuple2<ValidateResponseCode, GameAction> _doConvert(ConvertAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.removeResource(action.source);
    convertedResources[action.destination].value = convertedResources[action.destination].value + 1;
    action.producedBy.activated.value = true;
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doDoubleConvert(DoubleConvertAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.removeResource(action.source);
    convertedResources[action.source].value = convertedResources[action.source].value + 2;
    action.producedBy.activated.value = true;
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doMysteryMeat(MysteryMeatAction action) {
    var ret = ValidateResponseCode.ok;

    if (player.hasResourceStorageSpace) {
      changeStack.group();
      action.resource = game.getFromWell();
      player.storeResource(action.resource);
      action.producedBy.activated.value = true;
      _fixResourceAcquireProducts(player);
      changeStack.commit();
      changeStack.clear();
    } else {
      ValidateResponseCode.noStorage;
    }
    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doVp(VpAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    player.giveVpChit();
    action.producedBy.activated.value = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction> _doRequestAcquire(RequestAcquireAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    turnState.value = TurnState.acquireRequested;
    action.producedBy.activated.value = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction>(ret, null);
  }
}
