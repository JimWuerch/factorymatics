import 'dart:async';
import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';
import 'package:factorymatics/src/game_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dialogs/ask_payment_dialog.dart';
import 'dialogs/ask_search_deck_dialog.dart';
import 'display_sizes.dart';

enum SearchExecutionOptions { doNothing, construct, store, unselected }

class GamePageModel {
  DisplaySizes displaySizes = DisplaySizes();

  Game/*!*/ game;
  String/*!*/ playerId; // = 'id1';
  String/*!*/ playerName; // = 'bob';
  PlayerData displayPlayer;
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  List<GameAction> availableActions = <GameAction>[];
  final BuildContext gamePageContext;
  final GameInfoModel/*!*/ gameInfoModel;
  SearchExecutionOptions _searchExecutionOption = SearchExecutionOptions.unselected;
  bool showWait = false;

  GamePageModel(this.gameInfoModel, this.gamePageContext);

  Future<void> init() async {
    await doGameUpdate();
  }

  void RequestUpdate() {
    _notifierController.add(2);
  }

  /// Update the game state.  Set [noNotify] to true to prevent listeners from getting notified
  Future<void> doGameUpdate({bool noNotify = false}) async {
    var response = await gameInfoModel.client.postRequest(JoinGameRequest(gameInfoModel.gameId, playerId));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError('JoinGameRequest response:${response.responseCode.name}');
    }
    if (response is JoinGameResponse) {
      game = GameController.restoreGame(null, response.gameState);
      game.tmpName = 'client';
      if (game.currentTurn != null) {
        availableActions = game.currentTurn.getAvailableActions();
      }
      if (gameInfoModel.client is LocalClient) {
        var showTurnDlg = false;
        if (displayPlayer == null) {
          displayPlayer = game.currentPlayer;
          showTurnDlg = true;
        } else {
          // we make a new game object so we need to refresh the player object
          displayPlayer = game.getPlayerFromId(displayPlayer.id);
        }
        if (game.currentPlayer.id != playerId || showTurnDlg) {
          playerId = game.currentPlayer.id;
          playerName = game.currentPlayer.id;
          if (!isGameEnded) {
            showDialog<void>(
              context: gamePageContext,
              builder: (context) {
                return AlertDialog(
                  title: const Text('New Turn'),
                  content: Text('Player $playerName\'s turn'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // TODO: remove this
            SystemSound.play(SystemSoundType.alert);
          }
        }
      } else {
        // not a local game
        displayPlayer = game.getPlayerFromId(playerId);
      }

      // start turn if it's our turn
      // if (isOurTurn && (game.currentTurn.turnState.value == TurnState.notStarted)) {
      //   doStartTurn();
      //   await doGameUpdate(noNotify: true);
      // }
      _searchExecutionOption = SearchExecutionOptions.unselected;
      showWait = false;
      _notifierController.add(1);
    } else {
      _notifierController.addError('Response not JoinGameResponse');
    }
  }

  // Future<void> doStartTurn() async {
  //   var startTurnResponse = await gameInfoModel.client.postAction(game, GameModeAction(playerId, GameModeType.startTurn));
  //   if (startTurnResponse.responseCode != ResponseCode.ok) {
  //     _notifierController.addError(null);
  //   }
  // }

  bool get isGameEnded => game.currentTurn.turnState.value == TurnState.gameEnded;
  bool get isActionSelection => game.currentTurn?.turnState?.value == TurnState.started;

  bool get isResourcePickerEnabled => ((game.currentTurn?.selectedAction?.value == ActionType.acquire &&
          game.currentTurn?.turnState?.value == TurnState.actionSelected) ||
      game.currentTurn?.turnState?.value == TurnState.acquireRequested);

  bool get isOurTurn => game.currentPlayer.id == playerName;
  bool get isActivePlayer => !showWait && displayPlayer.id == game.currentPlayer.id;

  bool get canUndo => game.canUndo && isOurTurn;

  bool get canEndTurn => isOurTurn && game.currentTurn?.turnState?.value == TurnState.selectedActionCompleted;

  List<Part> get searchedParts => game.currentTurn.searchedParts.list;

  SearchExecutionOptions get searchExecutionOption => _searchExecutionOption;
  set searchExecutionOption(SearchExecutionOptions value) {
    _searchExecutionOption = value;
    _notifierController.add(1); // redraw gamepage
  }

  Map<ResourceType, int> getAvailableResources() {
    var ret = <ResourceType, int>{};
    //var player = game.getPlayerFromId(displayPlayer.id)
    for (var item in displayPlayer.resources.entries) {
      ret[item.key] = item.value.value;
    }
    return ret;
  }

  Future<void> selectAction(ActionType actionType) async {
    switch (actionType) {
      case ActionType.store:
        await _selectStore();
        break;
      case ActionType.acquire:
        await _selectAcquire();
        break;
      case ActionType.construct:
        await _selectConstruct();
        break;
      case ActionType.search:
        await _selectSearch();
        break;
      default:
        throw ArgumentError('Unknown type: ${actionType.toString()}');
    }
  }

  bool isPartEnabled(Part part) {
    for (var action in availableActions) {
      if (action is StoreAction && (!inSearch || (searchExecutionOption == SearchExecutionOptions.store))) {
        if (part.id == action.part.id) {
          return true;
        }
      } else if (action is ConstructAction &&
          (!inSearch || (searchExecutionOption == SearchExecutionOptions.construct))) {
        if (part.id == action.part.id) {
          return true;
        }
      }
    }
    return false;
  }

  HashSet<String> getEnabledParts() {
    var ret = HashSet<String>();
    //Map<ResourceType, List<List<Product>>> max;
    for (var action in availableActions) {
      if (action is StoreAction &&
          ((game.currentTurn.turnState.value == TurnState.searchSelected &&
                  searchExecutionOption == SearchExecutionOptions.store) ||
              game.currentTurn.turnState.value != TurnState.searchSelected)) {
        ret.add(action.part.id);
      } else if (action is ConstructAction &&
          ((game.currentTurn.turnState.value == TurnState.searchSelected &&
                  searchExecutionOption == SearchExecutionOptions.construct) ||
              game.currentTurn.turnState.value != TurnState.searchSelected)) {
        ret.add(action.part.id);
      }
    }
    return ret;
  }

  bool get canStore => game.currentPlayer.hasPartStorageSpace;

  bool get canAcquire => game.currentPlayer.hasResourceStorageSpace;

  bool get canSearch => game.currentPlayer.canSearch;

  bool get canConstruct => game.currentTurn.getAffordableParts().isNotEmpty;

  bool get inSearch => game.currentTurn.turnState.value == TurnState.searchSelected;

  bool/*!*/ isPartReady(Part part) => game.currentTurn.partReady[part.id];
  bool/*!*/ isProductActivated(Product product) => game.currentTurn.productActivated[product.productCode];

  bool isActivationAllowed(Product product) {
    for (var action in availableActions) {
      if (action.producedBy != null &&
          action.producedBy/*!*/.part.id == product.part.id &&
          action.producedBy/*!*/.prodIndex == product.prodIndex) {
        return true;
      }
    }
    return false;
  }

  Future<ResponseCode> _postAction(GameAction action) async {
    var response = await gameInfoModel.client.postAction(game, action);
    if (response.responseCode != ResponseCode.ok) {
      return response.responseCode;
    }
    await doGameUpdate();

    return response.responseCode;
  }

  Future<ResponseCode> _selectStore() async {
    return await _postAction(SelectActionAction(playerId, ActionType.store));
  }

  Future<void> _selectAcquire() async {
    return await _postAction(SelectActionAction(playerId, ActionType.acquire));
  }

  Future<void> _selectConstruct() async {
    return await _postAction(SelectActionAction(playerId, ActionType.construct));
  }

  Future<void> _selectSearch() async {
    var level = await showAskSearchDeckDialog(gamePageContext, game);
    if (level == null) return;
    var response = await gameInfoModel.client.postAction(game, SelectActionAction(playerId, ActionType.search));
    if (response.responseCode != ResponseCode.ok) {
      // TODO: report error to player
      _notifierController.addError('SelectActionAction with search response: ${response.responseCode.name}');
      return;
    }

    response = await gameInfoModel.client.postAction(game, SearchAction(playerId, level));
    if (response.responseCode != ResponseCode.ok) {
      // try to undo the previous action
      doUndo();
      _notifierController.addError('Unwinding search action, ${response.responseCode.name}');
      return;
    }

    return await doGameUpdate();
  }

  Future<void> resourceSelected(int index) async {
    return await _postAction(AcquireAction(playerId, index, null));
  }

  Future<void> playerNameTapped(String playerId) async {
    displayPlayer = game.getPlayerFromId(playerId);
    return await doGameUpdate();
  }

  Future<GameAction> _handleConstructRequest(Part part) async {
    // is the part free as a result of a product?
    if (game.currentTurn.turnState.value == TurnState.constructL1Requested && part.level == 0) {
      return ConstructAction(playerId, part, [], null, null);
    }
    // is the part free because of discounts?
    var discount = game.currentTurn.partDiscount(part);
    if (part.cost - discount == 0) {
      return ConstructAction(playerId, part, [], null, null);
    }

    var paths = game.currentPlayer.getPayments(part, discount, game.currentTurn);
    if (paths.isEmpty) {
      throw InvalidOperationError('No way to pay for part ${part.id}');
    }

    var index = 0;
    if (paths.length != 1) {
      // more than 1 way to pay, ask user for which one
      index = await showAskPaymentDialog(gamePageContext, paths);
      if (index == null) {
        return null;
      }
    }

    // run the converters for the selected payment path
    var convertersUsed = <GameAction>[];
    for (var used in paths[index].history) {
      if (used.product.productType != ProductType.spend) {
        convertersUsed.add(used.product.produce(playerId));
      }
    }

    List<ResourceType> payment;
    if (part.resource == ResourceType.any) {
      //payment = paths[index].getCost().toList();
      payment = paths[index].getOutput().toList();
    } else {
      payment = List<ResourceType>.filled(part.cost - discount, part.resource);
    }
    return ConstructAction(playerId, part, payment, null, convertersUsed.isNotEmpty ? convertersUsed : null);
  }

  Future<void> partTapped(Part part) async {
    GameAction action;
    if (game.currentTurn.turnState.value == TurnState.actionSelected) {
      if (game.currentTurn.selectedAction.value == ActionType.store) {
        action = StoreAction(playerId, part, null);
      } else if (game.currentTurn.selectedAction.value == ActionType.construct) {
        action = await _handleConstructRequest(part); // ConstructAction(playerId, part, payment, null);
      }
    } else if (game.currentTurn.turnState.value == TurnState.searchSelected) {
      if (searchExecutionOption == SearchExecutionOptions.construct) {
        action = await _handleConstructRequest(part); // ConstructAction(playerId, part, payment, null);
      } else if (searchExecutionOption == SearchExecutionOptions.store) {
        action = StoreAction(playerId, part, null);
      }
    } else if (game.currentTurn.turnState.value == TurnState.storeRequested) {
      action = StoreAction(playerId, part, null);
    } else if (game.currentTurn.turnState.value == TurnState.constructL1Requested) {
      action = await _handleConstructRequest(part);
    }
    if (action != null) {
      var response = await gameInfoModel.client.postAction(game, action);
      if (response.responseCode != ResponseCode.ok) {
        _notifierController.addError('Action ${action.actionType.name} response ${response.responseCode.name}');
        return;
        // response.responseCode;
      }
      await doGameUpdate();
    }
    return;
  }

  Future<void> handleSearchProduct(SearchProduct product) async {
    if (product == null) return;

    var level = await showAskSearchDeckDialog(gamePageContext, game);
    if (level == null) return;

    GameAction action;
    action = product.produce(playerId);

    var response = await gameInfoModel.client.postAction(game, action);
    if (response.responseCode != ResponseCode.ok) {
      // TODO: log something here
      return;
      // response.responseCode;
    }
    action = SearchAction(playerId, level);
    response = await gameInfoModel.client.postAction(game, action);
    if (response.responseCode != ResponseCode.ok) {
      // TODO: log something here
      return;
      // response.responseCode;
    }
    await doGameUpdate();
  }

  Future<void> productTapped(Product product) async {
    // acquire is handled elsewhere
    //if (product.productType == ProductType.aquire) return;

    if (product is SearchProduct) {
      return handleSearchProduct(product);
    }

    GameAction action;
    action = product.produce(playerId);

    if (action != null) {
      var response = await gameInfoModel.client.postAction(game, action);
      if (response.responseCode != ResponseCode.ok) {
        //return;
        // response.responseCode;
      }
      await doGameUpdate();
    }
    return;
  }

  Future<void> doUndo() async {
    _searchExecutionOption = SearchExecutionOptions.unselected;
    await _postAction(GameModeAction(playerId, GameModeType.undo));
  }

  Future<void> doEndTurn() async {
    displayPlayer = null;
    await _postAction(GameModeAction(playerId, GameModeType.endTurn));
  }

  int unusedProducts() {
    return game.currentTurn.unusedProductCount();
  }

  Future<void> onSearchActionTapped(SearchExecutionOptions option) async {
    if (option == SearchExecutionOptions.doNothing) {
      await _postAction(SearchDeclinedAction(playerId));
    } else if (option != SearchExecutionOptions.unselected) {
      searchExecutionOption = option; // will call gameUpdate
    }
  }

  Future<void> onDoAiTurn() async {
    await _postAction(GameModeAction(playerId, GameModeType.doAiTurn));
  }
}
