import 'package:engine/engine.dart';
import 'game_store.dart';
import 'transport.dart';

typedef ClientCallback = void Function(GameAction);

/// This is just a local server for now, it will run inside the client
class GameServer {
  //Game game;
  int gameId;
  // final _serverActionsStreamController = StreamController<GameAction>.broadcast();
  // Stream<GameAction> get serverActions => _serverActionsStreamController.stream.asBroadcastStream();
  // StreamSubscription<GameAction> gameActions;
  ClientCallback clientCallback;
  GameStore games = GameStore();
  GameTransport gameTransport;
  PlayerService playerService;

  GameServer(this.clientCallback) : playerService = PlayerService.createService();

  void createPlayer(String name, String id) {
    playerService.addPlayer(name, id);
  }

  void joinPlayerToGame(String gameId, String playerId) {
    games.addPlayer(gameId, playerService.getPlayer(playerId));
  }

  String createGameLobby(String playerId) {
    var lobby = games.createLobby();
    games.addPlayer(lobby.gameId, playerService.getPlayer(playerId));
    return lobby.gameId;
  }

  GameController createGame(String gameId) {
    var gc = GameController();
    gc.setupGame(games.findPlayers(gameId).map<String>((e) => e.playerId).toList(), playerService, gameId);
    games.store(gc);
    return gc;
  }

  void closeGame(String gameId) {
    if (gameId == null) return;
    var game = games.find(gameId);
    if (game == null) return;

    //game.dispose();
    games.delete(gameId);
  }

  bool doAction(String gameId, GameAction action) {
    var game = games.find(gameId).game;
    return false; //game.applyAction(action);
  }

  ResponseModel handleRequest(GameModel model) {
    //TODO: add validator
    // validateRequest(model);

    switch (model.modelType) {
      case GameModelType.createGameRequest:
        var request = model as CreateGameRequest;
        var gc = createGame(request.gameId);
        return CreateGameResponse(gc.game, model.ownerId, 'create game', ResponseCode.ok);

      case GameModelType.actionRequest:
        var request = model as ActionRequest;
        doAction(request.gameId, request.action);
        return null;

      case GameModelType.joinGameRequest:
        var request = model as JoinGameRequest;
        var gc = games.find(request.gameId);
        var gameState = gc.getGameState();
        return JoinGameResponse(gc.game, request.ownerId, 'joinGameResponse', ResponseCode.ok, gameState);

      case GameModelType.createLobbyRequest:
        var request = model as CreateLobbyRequest;
        playerService.addPlayer(request.playerName, request.ownerId);
        var lobby = createGameLobby(request.ownerId);
        return CreateLobbyResponse(lobby, request.ownerId, ResponseCode.ok);

      default:
        return null;
    }
  }
}
