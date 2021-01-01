import 'dart:async';
import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';

class GamePageModel {
  Game game;
  String gameId;
  LocalClient client;
  String playerId = 'id1';
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  PlayerService playerService;
  List<String> players;
  String playerName = 'bob';
  List<GameAction> availableActions = <GameAction>[];

  GamePageModel(this.gameId);

  Future<void> init() async {
    playerService = PlayerService.createService();
    client = LocalClient(playerId);
    var response = await client.postRequest(CreateLobbyRequest(playerId, 'game_name', 'bob', ''));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    gameId = (response as CreateLobbyResponse).gameId;
    response = await client.postRequest(CreateGameRequest(gameId, playerId));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    var createGameResponse = response as CreateGameResponse;
    if (createGameResponse != null) {
      players = createGameResponse.players;
      for (var player in createGameResponse.players) {
        playerService.addPlayer(player, player);
      }
    }
    await doGameUpdate();
  }

  /// Update the game state.  Set [nonNotify] to true to prevent listeners from getting notified
  Future<void> doGameUpdate({bool noNotify = false}) async {
    var response = await client.postRequest(JoinGameRequest(gameId, playerId));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    if (response is JoinGameResponse) {
      game = GameController.restoreGame(players, null, response.gameState);
      game.tmpName = 'client';
      if (game.currentTurn != null) {
        availableActions = game.currentTurn.getAvailableActions();
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
    var startTurnResponse = await client.postAction(game, GameModeAction(playerId, GameModeType.startTurn));
    if (startTurnResponse.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
  }

  bool get isActionSelection => game.currentTurn?.turnState?.value == TurnState.started;

  bool get isResourcePickerEnabled =>
      game.currentTurn?.selectedAction?.value == ActionType.acquire &&
      game.currentTurn?.turnState?.value == TurnState.actionSelected;

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
    var response = await client.postAction(game, action);
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
      }
    }
    if (action != null) {
      var response = await client.postAction(game, action);
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
}
