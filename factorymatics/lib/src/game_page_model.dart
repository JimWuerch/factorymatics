import 'dart:async';
import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';
import 'package:factorymatics/src/game_info_model.dart';
import 'package:flutter/material.dart';

import 'dialogs/ask_payment_dialog.dart';

class GamePageModel {
  Game game;

  String playerId; // = 'id1';
  String playerName; // = 'bob';
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  List<GameAction> availableActions = <GameAction>[];
  final BuildContext gamePageContext;
  final GameInfoModel gameInfoModel;

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
      }
      // start turn if it's our turn
      if (isOurTurn && (game.currentTurn.turnState.value == TurnState.notStarted)) {
        doStartTurn();
        await doGameUpdate(noNotify: true);
      }
      _notifierController.add(1);
    } else {
      _notifierController.addError(null);
    }
  }

  Future<void> doStartTurn() async {
    var startTurnResponse = await gameInfoModel.client.postAction(game, GameModeAction(playerId, GameModeType.startTurn));
    if (startTurnResponse.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
  }

  bool get isActionSelection => game.currentTurn?.turnState?.value == TurnState.started;

  bool get isResourcePickerEnabled => ((game.currentTurn?.selectedAction?.value == ActionType.acquire && game.currentTurn?.turnState?.value == TurnState.actionSelected) ||
      game.currentTurn?.turnState?.value == TurnState.acquireRequested);

  bool get isOurTurn => game.currentPlayer.id == playerName;

  bool get canUndo => game.canUndo;

  bool get canEndTurn => game.currentTurn?.turnState?.value == TurnState.selectedActionCompleted;

  Map<ResourceType, int> getAvailableResources() {
    var ret = <ResourceType, int>{};
    var player = game.getPlayerFromId(playerName);
    for (var item in player.resources.entries) {
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
      if (action is StoreAction) {
        if (part.id == action.part.id) {
          return true;
        }
      } else if (action is ConstructAction) {
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
      if (action is StoreAction) {
        ret.add(action.part.id);
      } else if (action is ConstructAction) {
        ret.add(action.part.id);
      }
    }
    return ret;
  }

  bool get canStore => game.currentTurn?.player?.hasPartStorageSpace ?? false;

  bool get canAcquire => game.currentTurn?.player?.hasResourceStorageSpace ?? false;

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

  Future<void> _selectSearch() async {}

  Future<void> resourceSelected(int index) async {
    return await _postAction(AcquireAction(playerId, index, null));
  }

  Future<void> partTapped(Part part) async {
    GameAction action;
    if (game.currentTurn.turnState.value == TurnState.actionSelected) {
      if (game.currentTurn.selectedAction.value == ActionType.store) {
        action = StoreAction(playerId, part, null);
      } else if (game.currentTurn.selectedAction.value == ActionType.construct) {
        //action = ConstructAction(playerId, part, payment, null)
        var paths = game.currentPlayer.getPayments(part);
        if (paths.isEmpty) {
          throw InvalidOperationError('No way to pay for part ${part.id}');
        }

        var index = 0;
        if (paths.length != 1) {
          // more than 1 way to pay, ask user for which one
          index = await showAskPaymentDialog(gamePageContext, paths);
          if (index == null) {
            return;
          }
        }

        // run the converters for the selected payment path
        for (var used in paths[index].history) {
          if (used.product.productType != ProductType.spend) {
            var act = used.product.produce(game, playerId);
            var response = await gameInfoModel.client.postAction(game, act);
            if (response.responseCode != ResponseCode.ok) {
              _notifierController.addError(null);
            }
          }
        }

        List<ResourceType> payment;
        if (part.resource == ResourceType.any) {
          payment = paths[index].getCost().toList();
        } else {
          payment = List<ResourceType>.filled(part.cost, part.resource);
        }
        action = ConstructAction(playerId, part, payment, null);
      }
    }
    if (action != null) {
      var response = await gameInfoModel.client.postAction(game, action);
      if (response.responseCode != ResponseCode.ok) {
        _notifierController.addError(null);
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
    await _postAction(GameModeAction(playerId, GameModeType.undo));
  }

  Future<void> doEndTurn() async {
    await _postAction(GameModeAction(playerId, GameModeType.endTurn));
  }

  int unusedProducts() {
    return game.currentPlayer.unusedProductCount();
  }
}
