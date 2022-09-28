import 'dart:collection';
import 'dart:convert';

import 'package:engine/engine.dart';
import 'package:tuple/tuple.dart';

enum ValidateResponseCode { ok, notAllowed, noStorage, cantAfford, partNotForSale, unknownAction, outOfTurn }

enum TurnState {
  notStarted, // waiting for start turn action
  started, // waiting for SelectActionAction
  actionSelected, // received SelectActionAction
  searchSelected, // if the selectedAction is search, this state is waiting for the deck choice
  selectedActionCompleted, // ready to handle triggered actions
  searchRequested, // search as a result of product triggered
  acquireRequested, // acquire request as result of product triggered
  constructL1Requested, // construct a free L1 part requested as a result of product triggered
  storeRequested, // store request as a result of a product triggered
  ended, // received end turn action
  gameEnded, // end of game detected, no more allowed actions
}

class Turn {
  final Game game;
  final PlayerData player;
  final GameStateVar<TurnState> turnState;
  final GameStateVar<ActionType?> selectedAction;
  final ChangeStack changeStack;
  final Map<ResourceType, GameStateVar<int>> convertedResources;
  final ListState<Part> searchedParts;
  DefaultValueMapState<String, bool> partReady;
  DefaultValueMapState<String, bool> productActivated;

  bool get gameEnded => turnState.value == TurnState.gameEnded;

  Turn(this.game, this.player)
      : changeStack = ChangeStack(),
        turnState = GameStateVar(game, 'turnState', TurnState.notStarted),
        selectedAction = GameStateVar(game, 'selectedAction', null),
        convertedResources = <ResourceType, GameStateVar<int>>{},
        searchedParts = ListState<Part>(game, 'searchedParts'),
        partReady = DefaultValueMapState(game, "turn:partReady", false),
        productActivated = DefaultValueMapState(game, "turn:productActivated", false) {
    PlayerData.initResourceMap(game, convertedResources, 'cRes');
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{
      //'player': player.id,
      'state': TurnState.values.indexOf(turnState.value!),
    };
    if (selectedAction.value != null) {
      ret['selectedAction'] = ActionType.values.indexOf(selectedAction.value!);
    }
    var p = <String>[];
    for (var part in searchedParts) {
      p.add(part.id);
    }
    ret['searchedParts'] = p;
    var convertedResString = resourceMapStateToString(convertedResources);
    if (convertedResString.isNotEmpty) {
      ret['convRes'] = convertedResString;
    }
    ret['ready'] = jsonEncode(partReady.getMap);
    ret['activated'] = jsonEncode(productActivated.getMap);

    return ret;
  }

  Turn._fromJsonHelper(this.game, this.player, TurnState state, ActionType? selected, List<Part> searchedParts,
      this.convertedResources, Map<String, bool> ready, Map<String, bool> activated)
      : changeStack = ChangeStack(),
        turnState = GameStateVar(game, 'turnState', state),
        selectedAction = GameStateVar(game, 'selectedAction', selected),
        searchedParts = ListState<Part>(game, 'searchedParts', starting: searchedParts),
        partReady = DefaultValueMapState(game, 'turn:partReady', false, starting: ready),
        productActivated = DefaultValueMapState(game, 'turn:productActivated', false, starting: activated) {
    if (state != TurnState.notStarted) {
      game.changeStack = changeStack;
    }
  }

  factory Turn.fromJson(Game game, PlayerData player, Map<String, dynamic> json) {
    //var player = game.getPlayerFromId(json['player'] as String);
    var turnState = TurnState.values[json['state'] as int];
    ActionType? selectedAction;
    if (json.containsKey('selectedAction')) {
      selectedAction = ActionType.values[json['selectedAction'] as int];
    }
    var searchedParts = <Part>[];
    if (json.containsKey('searchedParts')) {
      var plist = listFromJson<String>(json['searchedParts']);
      //searchedParts = <Part>[];
      for (var p in plist) {
        searchedParts.add(allParts[p]!);
      }
    }
    var res = stringToResourceMap(json['res'] as String?);
    var convRes = <ResourceType, GameStateVar<int>>{};
    PlayerData.initResourceMap(game, convRes, 'cRes');
    convRes[ResourceType.heart]!.reinitialize(res[ResourceType.heart]);
    convRes[ResourceType.club]!.reinitialize(res[ResourceType.club]);
    convRes[ResourceType.spade]!.reinitialize(res[ResourceType.spade]);
    convRes[ResourceType.diamond]!.reinitialize(res[ResourceType.diamond]);

    var ready = mapFromJson<String, bool>(jsonDecode(json['ready'] as String));
    var activated = mapFromJson<String, bool>(jsonDecode(json['activated'] as String));
    return Turn._fromJsonHelper(game, player, turnState, selectedAction, searchedParts, convRes, ready, activated);
  }

  /// Returns a list of possible actions for the current state of the turn
  /// When [isAi] is true, don't include non-active actions, like undo, end turn, etc
  List<GameAction> getAvailableActions({bool isAi = false}) {
    var ret = <GameAction>[];

    if (turnState.value == TurnState.gameEnded) {
      return ret;
    }

    if (changeStack.canUndo && !isAi) {
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
      if (player.hasPartStorageSpace && player.canStore) {
        ret.add(SelectActionAction(player.id, ActionType.store));
      }
      if (player.hasResourceStorageSpace) {
        ret.add(SelectActionAction(player.id, ActionType.acquire));
      }
      if (getAffordableParts().isNotEmpty) {
        ret.add(SelectActionAction(player.id, ActionType.construct));
      }
      if (player.canSearch) {
        ret.add(SelectActionAction(player.id, ActionType.search));
      }
      if (ret.isEmpty) {
        // allowed to end the turn now, in case we're completely stuck
        if (!isAi) {
          ret.add(GameModeAction(player.id, GameModeType.endTurn));
        }
      }
      return ret;
    }

    // converter actions are available at this point
    if (!isAi) {
      for (var part in player.parts[PartType.converter]!) {
        for (var product in part.products) {
          if (!productActivated[product.productCode]!) {
            _addAllAvailableActions(ret, part, product.produce(player.id));
          }
        }
      }
    }

    // did we do the action we selected yet?
    if (turnState.value == TurnState.actionSelected) {
      _addAllAvailableActions(ret, null, SelectActionAction(player.id, selectedAction.value!));
      return ret;
    }

    // we can build or store one of the parts we searched
    if (turnState.value == TurnState.searchSelected) {
      _addSearchedPartActions(ret);
      return ret;
    }

    if (turnState.value == TurnState.searchRequested) {
      _addSearchActions(ret);
      return ret;
    }

    if (turnState.value == TurnState.acquireRequested) {
      _addAllAvailableActions(ret, null, AcquireAction(player.id, -1, null));
      return ret;
    }

    if (turnState.value == TurnState.constructL1Requested) {
      _addFreeConstructL1Actions(ret);
      return ret;
    }

    if (turnState.value == TurnState.storeRequested) {
      _addStorePartActions(ret, null);
      return ret;
    }

    if (turnState.value == TurnState.selectedActionCompleted) {
      // we know an action has been selected and completed, so now we can add all
      // the actions that triggered parts produce

      // allowed to end the turn now
      if (!isAi) {
        ret.add(GameModeAction(player.id, GameModeType.endTurn));
      }

      // triggered actions
      for (var partList in player.parts.values) {
        for (var part in partList) {
          if (part.partType == PartType.storage ||
              part.partType == PartType.acquire ||
              part.partType == PartType.construct) {
            if (partReady[part.id]!) {
              for (var product in part.products) {
                if (!productActivated[product.productCode]! && _productCanActivate(product)) {
                  // if (product.productType == ProductType.aquire || product.productType == ProductType.mysteryMeat) {
                  //   if (!player.hasResourceStorageSpace) {
                  //     continue;
                  //   }
                  // } else if (product.productType == ProductType.store &&
                  //     (!player.hasPartStorageSpace || !player.canStore)) {
                  //   continue;
                  // } else if (product.productType == ProductType.freeConstructL1 && game.saleParts[0].isEmpty) {
                  //   continue;
                  // } else if (product.productType == ProductType.search && !player.canSearch) {
                  //   continue;
                  // }
                  _addAllAvailableActions(ret, part, product.produce(player.id));
                }
              }
            }
          }
        }
      }
    }

    return ret;
  }

  /// Check to see if [product] is prevented from activating, even though it's ready
  bool _productCanActivate(Product product) {
    if (product.productType == ProductType.aquire || product.productType == ProductType.mysteryMeat) {
      if (!player.hasResourceStorageSpace) {
        return false;
      }
    } else if (product.productType == ProductType.store && (!player.hasPartStorageSpace || !player.canStore)) {
      return false;
    } else if (product.productType == ProductType.freeConstructL1 && game.saleParts[0].isEmpty) {
      return false;
    } else if (product.productType == ProductType.search && !player.canSearch) {
      return false;
    }
    return true;
  }

  void _addSearchedPartActions(List<GameAction> actions) {
    //if (searchedParts == null) return;
    for (var part in searchedParts) {
      if (player.canAfford(part, partDiscount(part), convertedResources, this)) {
        actions.add(ConstructAction(player.id, part, null, null, null));
      }
      if (player.hasPartStorageSpace) {
        actions.add(StoreAction(player.id, part, null));
      }
    }
    actions.add(SearchDeclinedAction(player.id, null));
  }

  void _addFreeConstructL1Actions(List<GameAction> actions) {
    for (var part in game.saleParts[0].list) {
      actions.add(ConstructAction(player.id, part, null, null, null));
    }
  }

  void _addSearchActions(List<GameAction> actions) {
    for (var level = 0; level < 3; ++level) {
      if (game.partsRemaining[level] > 0) {
        actions.add(SearchAction(player.id, level));
      }
    }
  }

  void _addAllAvailableActions(List<GameAction> actions, Part? part, GameAction action) {
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
          _addAffordablePartActions(actions, null);
          break;

        case ActionType.search:
          // can search one of the 3 decks
          _addSearchActions(actions);
          break;

        default:
          break;
      }
    } else if (action is MysteryMeatAction) {
      actions.add(action);
    } else if (action is AcquireAction) {
      actions.add(action);
    } else if (action is ConvertAction) {
      if (action.source == ResourceType.any) {
        if (player.maxResources == null) {
          player.updateMaxResources(this);
        }
        if (player.maxResources!.getResourceCount() > 0) {
          actions.add(action);
        } else if (convertedResources[ResourceType.heart]!.value! > 0 ||
            convertedResources[ResourceType.spade]!.value! > 0 ||
            convertedResources[ResourceType.club]!.value! > 0 ||
            convertedResources[ResourceType.diamond]!.value! > 0) {
          actions.add(action);
        }
      } else {
        if (player.hasResource(action.source) || convertedResources[action.source]!.value! > 0) {
          actions.add(action);
        }
      }
    } else if (action is DoubleConvertAction) {
      if (player.hasResource(action.source) || convertedResources[action.source]!.value! > 0) {
        actions.add(action);
      }
    } else if (action is RequestAcquireAction) {
      actions.add(action);
    } else if (action is SearchDeclinedAction) {
      actions.add(action);
    } else if (action is RequestSearchAction) {
      actions.add(action);
    } else if (action is RequestConstructL1Action) {
      actions.add(action);
    } else if (action is RequestStoreAction) {
      actions.add(action);
    }
  }

  void _addStorePartActions(List<GameAction> actions, Product? producedBy) {
    if (player.hasPartStorageSpace) {
      for (var i = 0; i < 3; ++i) {
        for (var part in game.saleParts[i]) {
          actions.add(StoreAction(player.id, part, producedBy));
        }
      }
    }
  }

  // TODO: use this in getAffordableParts
  /// Part discount
  int partDiscount(Part part) {
    var discount = 0;
    if (part.level == 1) discount += player.constructLevel2Discount;

    if (turnState.value == TurnState.searchSelected) {
      if (searchedParts.contains(part) == true) {
        discount += player.constructFromSearchDiscount;
      }
    } else if (player.isInStorage(part)) {
      discount += player.constructFromStoreDiscount;
    }

    if (discount > part.cost) {
      discount = part.cost;
    }

    return discount;
  }

  HashSet<Part> getAffordableParts() {
    var items = HashSet<Part>();
    var discount = 0;
    // if we have searched, only consider those parts
    if (turnState.value == TurnState.searchSelected) {
      for (var part in searchedParts) {
        var dis = discount + player.constructFromSearchDiscount;
        if (part.level == 1) dis += player.constructLevel2Discount;
        if (dis > part.cost) {
          dis = part.cost;
        }
        if (player.canAfford(part, dis, convertedResources, this)) {
          items.add(part);
        }
      }
    } else {
      // not searching, so look at the stuff for sale and storage
      for (var i = 0; i < 3; ++i) {
        for (var part in game.saleParts[i]) {
          var dis = discount;
          if (part.level == 1) dis += player.constructLevel2Discount;
          if (dis > part.cost) {
            dis = part.cost;
          }
          if (player.canAfford(part, dis, convertedResources, this)) {
            items.add(part);
          }
        }
      }
      for (var part in player.savedParts) {
        var dis = discount;
        if (part.level == 1) dis += player.constructLevel2Discount;
        dis += player.constructFromStoreDiscount;
        if (dis > part.cost) {
          dis = part.cost;
        }
        if (player.canAfford(part, dis, convertedResources, this)) {
          items.add(part);
        }
      }
    }
    return items;
  }

  void _addAffordablePartActions(List<GameAction> actions, Product? producedBy) {
    var parts = getAffordableParts();
    for (var part in parts) {
      actions.add(ConstructAction(player.id, part, <ResourceType>[], producedBy, null));
    }
  }

  void resetPartActivations() {
    partReady.reinitialize();
    productActivated.reinitialize();
  }

  void startTurn() {
    game.changeStack = changeStack;
    resetPartActivations();
    // converters don't rely on previous triggers, so enable them
    for (var part in player.parts[PartType.converter]!) {
      partReady[part.id] = true;
    }
    turnState.value = TurnState.started;
    changeStack.clear();
  }

  void endTurn() {
    turnState.value = TurnState.ended;
    for (var item in convertedResources.values) {
      item.value = 0;
    }
    if (!game.gameEndTriggered) {
      game.gameEndTriggered = (player.partCount > 15) || (player.level3PartCount > 3);
    }

    changeStack.clear();
    //game.changeStack = null;
    game.endTurn();
  }

  void setGameComplete() {
    turnState.value = TurnState.gameEnded;
  }

  // check to see if the player is even allowed to do the action
  GameAction? _isAvailableAction(GameAction action) {
    var availableActions = getAvailableActions();
    for (var a in availableActions) {
      if (a.matches(action)) return a;
    }
    // if we got here, the action wasn't in the available list
    return null;
  }

  Tuple2<ValidateResponseCode, GameAction?> processAction(GameAction action) {
    if (action.owner != player.id) {
      log.info('Action requested by non-current player ${action.owner}');
      return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.notAllowed, null);
    }

    if (!game.testMode) {
      var matchedAction = _isAvailableAction(action);
      if (matchedAction == null) {
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.notAllowed, null);
      }
    }

    // the source may not know who made the action available
    //action.producedBy == matchedAction.producedBy;

    switch (action.actionType) {
      case ActionType.gameMode:
        if (action is GameModeAction) {
          if (action.mode == GameModeType.startTurn) {
            startTurn();
            return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.ok, null);
          } else if (action.mode == GameModeType.endTurn) {
            endTurn();
            return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.ok, null);
          } else if (action.mode == GameModeType.undo) {
            if (changeStack.canUndo) {
              changeStack.undo();
              return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.ok, null);
            } else {
              return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.notAllowed, null);
            }
          }
        }
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.notAllowed, null);
      case ActionType.selectAction:
        changeStack.group();
        var a = action as SelectActionAction;
        selectedAction.value = a.selectedAction;
        turnState.value = TurnState.actionSelected;
        changeStack.commit();
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.ok, null);
      case ActionType.store:
        return _doStore(action as StoreAction);
      case ActionType.construct:
        return _doConstruct(action as ConstructAction);
      case ActionType.acquire:
        return _doAcquire(action as AcquireAction);
      case ActionType.search:
        return _doSearch(action as SearchAction);
      case ActionType.convert:
        return _doConvert(action as ConvertAction);
      case ActionType.doubleConvert:
        return _doDoubleConvert(action as DoubleConvertAction);
      case ActionType.mysteryMeat:
        return _doMysteryMeat(action as MysteryMeatAction);
      case ActionType.vp:
        return _doVp(action as VpAction);
      case ActionType.requestAcquire:
        return _doRequestAcquire(action as RequestAcquireAction);
      case ActionType.searchDeclined:
        return _doSearchDeclined(action as SearchDeclinedAction);
      case ActionType.requestSearch:
        return _doRequestSearch(action as RequestSearchAction);
      case ActionType.requestConstructL1:
        return _doRequestConstructL1(action as RequestConstructL1Action);
      case ActionType.requestStore:
        return _doRequestStore(action as RequestStoreAction);
      default:
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.unknownAction, null);
    }
  }

  void _doTriggers(Game game, GameAction gameAction, PartType partType, Part? srcPart) {
    for (var part in player.parts[partType]!) {
      if (srcPart == part) {
        // don't trigger ourself
        continue;
      }
      if (!partReady[part.id]!) {
        for (var trigger in part.triggers) {
          if (trigger.isTriggeredBy(gameAction)) {
            partReady[part.id] = true;
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
      if (!productActivated[product.productCode]! && product is VpProduct) {
        _doVp((product.produce(playerId)) as VpAction);
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
          if (!productActivated[product.productCode]! &&
              (product.productType == ProductType.aquire || product.productType == ProductType.mysteryMeat)) {
            productActivated[product.productCode] = true;
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

  ValidateResponseCode _doSearchCompleted(Part? part) {
    if (part != null && (searchedParts.contains(part) != true || turnState.value != TurnState.searchSelected)) {
      return ValidateResponseCode.notAllowed;
    }

    if (part != null) {
      searchedParts.remove(part);
    }
    for (var part in searchedParts) {
      game.returnPart(part);
    }

    turnState.value = TurnState.selectedActionCompleted;

    return ValidateResponseCode.ok;
  }

  Tuple2<ValidateResponseCode, GameAction?> _doStore(StoreAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    player.savePart(action.part);

    if (turnState.value == TurnState.searchSelected) {
      ret = _doSearchCompleted(action.part);
      if (ValidateResponseCode.ok != ret) {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
      }
    } else {
      game.removePart(action.part);
    }

    if (action.producedBy != null) {
      productActivated[action.producedBy!.productCode] = true;
    }

    _doTriggers(game, action, PartType.storage, action.part);

    if (turnState.value == TurnState.actionSelected || turnState.value == TurnState.storeRequested) {
      turnState.value = TurnState.selectedActionCompleted;
    }

    game.refillMarket();
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doConstruct(ConstructAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    // run the converters needed
    if (action.convertersUsed != null) {
      for (var cv in action.convertersUsed!) {
        if (cv.actionType != ActionType.convert && cv.actionType != ActionType.doubleConvert) {
          log.severe('Player ${player.id} tried to use a non-converter action as a converter');
          changeStack.discard();
          return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.notAllowed, cv);
        }
        ret = processAction(cv).item1;
        if (ret != ValidateResponseCode.ok) {
          changeStack.discard();
          return Tuple2<ValidateResponseCode, GameAction>(ret, cv);
        }
      }
    }

    // force fromStorage to be accurate
    action.fromStorage = player.isInStorage(action.part);

    // do this first so we don't trigger ourself
    if (action.producedBy != null) {
      productActivated[action.producedBy!.productCode] = true;
    }

    if (turnState.value != TurnState.searchSelected) {
      if (game.isForSale(action.part) || game.isInDeck(action.part)) {
        game.removePart(action.part);
      } else if (player.isInStorage(action.part)) {
        player.unsavePart(action.part);
      } else {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.partNotForSale, null);
      }
    }

    // make player pay for the part if it isn't free
    if (turnState.value != TurnState.constructL1Requested) {
      var costRemaining = action.part.cost;
      if (action.part.level == 1) costRemaining -= player.constructLevel2Discount;
      if (action.fromStorage) costRemaining -= player.constructFromStoreDiscount;
      if (turnState.value == TurnState.searchSelected) costRemaining -= player.constructFromSearchDiscount;
      if (costRemaining < 0) {
        // in case we have lots of discounts
        costRemaining = 0;
      }
      for (var resource in action.payment!) {
        if (convertedResources[resource]!.value! > 0) {
          convertedResources[resource]!.value = convertedResources[resource]!.value! - 1;
        } else if (player.resources[resource]!.value! > 0) {
          player.removeResource(resource);
          game.addToWell(resource);
        } else {
          log.severe('Player ${player.id} failed to spend ${resource.name}');
          changeStack.discard();
          return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.notAllowed, null);
        }
        costRemaining--;
      }
      if (costRemaining != 0) {
        log.severe('Player ${player.id} failed to pay for ${action.part.id}');
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction?>(ValidateResponseCode.cantAfford, null);
      }
    }

    player.buyPart(action.part);
    _doTriggers(game, action, PartType.construct, action.part);

    // we can use the new part this turn
    if (action.part.partType == PartType.converter) {
      partReady[action.part.id] = true;
    }

    if (turnState.value == TurnState.searchSelected) {
      ret = _doSearchCompleted(action.part);
      if (ValidateResponseCode.ok != ret) {
        changeStack.discard();
        return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
      }
    } else if (turnState.value == TurnState.actionSelected || turnState.value == TurnState.constructL1Requested) {
      turnState.value = TurnState.selectedActionCompleted;
    }

    game.refillMarket();
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doAcquire(AcquireAction action) {
    var ret = ValidateResponseCode.ok;

    if (player.hasResourceStorageSpace) {
      changeStack.group();

      action.acquiredResource = game.acquireResource(action.index);
      player.storeResource(action.acquiredResource);

      if (action.producedBy != null) {
        productActivated[action.producedBy!.productCode] = true;
      }

      _doTriggers(game, action, PartType.acquire, null);

      if (turnState.value == TurnState.actionSelected || turnState.value == TurnState.acquireRequested) {
        turnState.value = TurnState.selectedActionCompleted;
      }

      changeStack.commit();
      // since we revealed info, no more undo
      changeStack.clear();
    } else {
      ret = ValidateResponseCode.noStorage;
    }
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doSearch(SearchAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    searchedParts.clear();
    //var parts = <String>[];
    for (var i = 0; i < player.search && game.partDecks[action.level].isNotEmpty; ++i) {
      var part = game.drawPart(action.level);
      searchedParts.add(part);
      //parts.add(part.id);
    }

    turnState.value = TurnState.searchSelected;

    changeStack.commit();
    // we looked at cards, no more undo
    changeStack.clear();

    // var result = SearchActionResult(player.id, parts);
    // return Tuple2<ValidateResponseCode, GameAction>(ret, result);
    // since we are serializing searchedParts, we don't need the specialized result
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doSearchDeclined(SearchDeclinedAction action) {
    changeStack.group();
    var ret = _doSearchCompleted(null);
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doConvert(ConvertAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    if (convertedResources[action.source]!.value! > 0) {
      convertedResources[action.source]!.value = convertedResources[action.source]!.value! - 1;
    } else if (player.resources[action.source]!.value! > 0) {
      player.removeResource(action.source);
      game.addToWell(action.source);
    } else {
      throw InvalidOperationError('tried to spend non-existence resource');
    }
    convertedResources[action.destination]!.value = convertedResources[action.destination]!.value! + 1;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doDoubleConvert(DoubleConvertAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();

    if (convertedResources[action.source]!.value! > 0) {
      convertedResources[action.source]!.value = convertedResources[action.source]!.value! - 1;
    } else if (player.resources[action.source]!.value! > 0) {
      player.removeResource(action.source);
      game.addToWell(action.source);
    } else {
      throw InvalidOperationError('tried to spend non-existence resource');
    }
    convertedResources[action.source]!.value = convertedResources[action.source]!.value! + 2;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doMysteryMeat(MysteryMeatAction action) {
    var ret = ValidateResponseCode.ok;

    if (player.hasResourceStorageSpace) {
      changeStack.group();
      action.resource = game.getFromWell();
      player.storeResource(action.resource);
      productActivated[action.producedBy!.productCode] = true;
      _fixResourceAcquireProducts(player);
      changeStack.commit();
      changeStack.clear();
    } else {
      ValidateResponseCode.noStorage;
    }
    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doVp(VpAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    for (var i = 0; i < action.vp; i++) {
      player.giveVpChit();
    }
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doRequestAcquire(RequestAcquireAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    turnState.value = TurnState.acquireRequested;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doRequestSearch(RequestSearchAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    turnState.value = TurnState.searchRequested;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doRequestConstructL1(RequestConstructL1Action action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    turnState.value = TurnState.constructL1Requested;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  Tuple2<ValidateResponseCode, GameAction?> _doRequestStore(RequestStoreAction action) {
    var ret = ValidateResponseCode.ok;
    changeStack.group();
    turnState.value = TurnState.storeRequested;
    productActivated[action.producedBy!.productCode] = true;
    changeStack.commit();

    return Tuple2<ValidateResponseCode, GameAction?>(ret, null);
  }

  int unusedProductCount() {
    var count = 0;
    for (var partType in player.parts.getMap.keys) {
      if (partType == PartType.storage || partType == PartType.acquire || partType == PartType.construct) {
        for (var part in player.parts[partType]!) {
          if (!partReady[part.id]!) continue;
          for (var product in part.products) {
            if (!productActivated[product.productCode]! && _productCanActivate(product)) {
              count++;
            }
          }
        }
      }
    }
    return count;
  }
}
