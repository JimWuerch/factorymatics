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

  GameServer(this.clientCallback);

  Game createGame(String gameId) {
    var game = Game(playerService, gameId);
    games.store(game);
    return game;
  }

  void closeGame(String gameId) {
    if (gameId == null) return;
    var game = games.find(gameId);
    if (game == null) return;

    //game.dispose();
    games.delete(gameId);
  }

  bool doAction(String gameId, GameAction action) {
    var game = games.find(gameId);
    return game.applyAction(action);
  }

  GameModel handleRequest(GameModel model) {
    //TODO: add validator
    // validateRequest(model);

    switch (model.modelType) {
      case GameModelType.createGameRequest:
        var request = model as CreateGameRequest;
        var game = createGame(request.gameId);
        game.startGame();
        return CreateGameResponse(game, model.ownerId, 'create game', game.gameId,
            game.playerService.players.map<String>((e) => e.name).toList());

      case GameModelType.actionRequest:
        var request = model as ActionRequest;
        doAction(request.gameId, request.action);
        return null;

      case GameModelType.joinGameRequest:
        var request = model as JoinGameRequest;
        var game = games.find(request.gameId);
        var turns = game.getTurns(request.turnIndex);
        return JoinGameResponse(game, request.ownerId, 'joinGameResponse', turns, ResponseCode.ok);

      default:
        return null;
    }
  }
}
