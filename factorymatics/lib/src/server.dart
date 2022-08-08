import 'dart:async';

import 'package:engine/engine.dart';
import 'package:server/server.dart';

abstract class Server {
  Stream<GameAction> get actions;
  void postAction(GameAction action);
}

class LocalServer extends Server {
  late GameServer server;
  final _streamController = StreamController<GameAction>.broadcast();
  late Stream<GameAction> _outboundActions;
  late LocalServerTransport transport;
  late Game _game;

  LocalServer() {
    server = GameServer(handleAction);
    transport = LocalServerTransport(server);
    _outboundActions = _streamController.stream.asBroadcastStream();
  }

  @override
  Stream<GameAction> get actions => _outboundActions;

  @override
  Future<ResponseModel> postAction(GameAction action) async {
    return await transport.sendRequest(ActionRequest(_game, action));
  }

  void handleAction(GameAction action) {
    _streamController.add(action);
  }

  // Future<Game> createGame(String gameId) async {
  //   //var response = server.handleRequest(CreateGameRequest('bob', gameIndex));
  //   var response = await transport.sendRequest(CreateGameRequest('bob', gameId));
  //   if (response is CreateGameResponse) {
  //     _playerService = PlayerService.createService();
  //     for (var player in response.players) {
  //       _playerService.addPlayer(player, player);
  //     }
  //     _game = Game(_playerService, response.gameId);
  //     return _game;
  //   } else {
  //     return null;
  //   }
  // }

  void closeGame() {
    //server.closeGame();
  }

  void startGame() {
    //server.doGame();
  }
}
