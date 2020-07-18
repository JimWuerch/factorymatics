import 'dart:async';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';

class GamePageModel {
  Game game;
  String gameId;
  LocalClient client;
  String playerId = 'id1';
  final StreamController<void> _notifierController = StreamController<void>.broadcast();
  Stream<void> get notifier => _notifierController.stream;
  PlayerService playerService;
  List<String> players;
  String playerName = 'bob';

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
    response = await client.postRequest(JoinGameRequest(gameId, playerId));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    if (response is JoinGameResponse) {
      game = GameController.restoreGame(createGameResponse.players, null, gameId);
      _notifierController.add(null);
    } else {
      _notifierController.addError(null);
    }
  }

  bool get isActionSelection => game.currentTurn?.turnState == TurnState.started;

  Future<void> selectAction(ActionType actionType) async {
    switch (actionType) {
      case ActionType.store:
        await _doStore();
        break;
      case ActionType.acquire:
        await _doAcquire();
        break;
      case ActionType.construct:
        await _doConstruct();
        break;
      case ActionType.search:
        await _doSearch();
        break;
      default:
        throw ArgumentError('Unknown type: ${actionType.toString()}');
    }
  }

  bool get canStore => game.currentTurn?.player?.hasPartStorageSpace ?? false;

  bool get canAcquire => game.currentTurn?.player?.hasResourceStorageSpace ?? false;

  Future<void> _doStore() async {}

  Future<void> _doAcquire() async {}

  Future<void> _doConstruct() async {}

  Future<void> _doSearch() async {}
}
