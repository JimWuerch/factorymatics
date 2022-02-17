import 'dart:async';
import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';
import 'package:factorymatics/src/game_info_model.dart';
import 'package:flutter/material.dart';

import 'dialogs/ask_payment_dialog.dart';
import 'dialogs/ask_search_deck_dialog.dart';

enum SearchExecutionOptions { doNothing, construct, store, unselected }

class GamePageModel {
  Game game;

  String playerId; // = 'id1';
  String playerName; // = 'bob';
  PlayerData displayPlayer;
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  List<GameAction> availableActions = <GameAction>[];
  final BuildContext gamePageContext;
  final GameInfoModel gameInfoModel;
  SearchExecutionOptions _searchExecutionOption = SearchExecutionOptions.unselected;

  GamePageModel(this.gameInfoModel, this.gamePageContext);

  Future<void> init() async {
    await doGameUpdate();
  }

  /// Update the game state.  Set [noNotify] to true to prevent listeners from getting notified
  Future<void> doGameUpdate({bool noNotify = false}) async {
    var response = await gameInfoModel.client.postRequest(JoinGameRequest(gameInfoModel.gameId, playerId));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    if (response is JoinGameResponse) {
      game = GameController.restoreGame(null, response.gameState);
      game.tmpName = 'client';
      if (game.currentTurn != null) {
        availableActions = game.currentTurn.getAvailableActions();
      }
      if (gameInfoModel.client is LocalClient) {
        if (displayPlayer == null) {
          displayPlayer = game.currentPlayer;
        } else {
          // we make a new game object so we need to refresh the player object
          displayPlayer = game.getPlayerFromId(displayPlayer.id);
        }
        if (game.currentPlayer.id != playerId) {
          playerId = game.currentPlayer.id;
          playerName = game.currentPlayer.id;
          await showDialog<void>(
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
      _notifierController.add(1);
    } else {
      _notifierController.addError(null);
    }
  }

  // Future<void> doStartTurn() async {
  //   var startTurnResponse = await gameInfoModel.client.postAction(game, GameModeAction(playerId, GameModeType.startTurn));
  //   if (startTurnResponse.responseCode != ResponseCode.ok) {
  //     _notifierController.addError(null);
  //   }
  // }

  bool get isGameEnded => game.currentTurn.gameEnded;
  bool get isActionSelection => game.currentTurn?.turnState?.value == TurnState.started;

  bool get isResourcePickerEnabled => ((game.currentTurn?.selectedAction?.value == ActionType.acquire &&
          game.currentTurn?.turnState?.value == TurnState.actionSelected) ||
      game.currentTurn?.turnState?.value == TurnState.acquireRequested);

  bool get isOurTurn => game.currentPlayer.id == playerName;
  bool get isActivePlayer => displayPlayer.id == game.currentPlayer.id;

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

  bool get canConstruct => game.currentTurn.getAffordableParts(0).isNotEmpty;

  bool get inSearch => game.currentTurn.turnState.value == TurnState.searchSelected;

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
      _notifierController.addError(null);
      return;
    }

    response = await gameInfoModel.client.postAction(game, SearchAction(playerId, level));
    if (response.responseCode != ResponseCode.ok) {
      // try to undo the previous action
      doUndo();
      _notifierController.addError(null);
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
    var paths = game.currentPlayer.getPayments(part);
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
        convertersUsed.add(used.product.produce(game, playerId));
        // var act = used.product.produce(game, playerId);
        // var response = await gameInfoModel.client.postAction(game, act);
        // if (response.responseCode != ResponseCode.ok) {
        //   _notifierController.addError(null);
        // }
      }
    }

    List<ResourceType> payment;
    if (part.resource == ResourceType.any) {
      payment = paths[index].getCost().toList();
    } else {
      payment = List<ResourceType>.filled(part.cost, part.resource);
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
    }
    if (action != null) {
      var response = await gameInfoModel.client.postAction(game, action);
      if (response.responseCode != ResponseCode.ok) {
        _notifierController.addError(1);
        return;
        // response.responseCode;
      }
      await doGameUpdate();
    }
    return;
  }

  Future<void> productTapped(Product product) async {
    // acquire is handled elsewhere
    //if (product.productType == ProductType.aquire) return;
    GameAction action;
    action = product.produce(game, playerId);

    if (action != null) {
      var response = await gameInfoModel.client.postAction(game, action);
      if (response.responseCode != ResponseCode.ok) {
        return;
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
    return game.currentPlayer.unusedProductCount();
  }

  Future<void> onSearchActionTapped(SearchExecutionOptions option) async {
    if (option == SearchExecutionOptions.doNothing) {
      await _postAction(SearchDeclinedAction(playerId));
    } else if (option != SearchExecutionOptions.unselected) {
      searchExecutionOption = option; // will call gameUpdate
    }
  }
}
