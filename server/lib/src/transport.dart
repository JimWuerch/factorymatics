import 'package:engine/engine.dart';

import 'game_server.dart';

typedef GameRequestCallback = void Function(GameModel model);

abstract class GameTransport {
  void init();
  Future<GameModel?> sendRequest(GameModel model);
}

class LocalServerTransport implements GameTransport {
  GameServer server;

  LocalServerTransport(this.server);

  Future<ResponseModel> receiveLocalRequest(Map<String, dynamic> json) async {
    var gameModelType = gameModelTypeFromJson(json);
    Game? game;
    if (gameModelType == GameModelType.actionRequest ||
        gameModelType == GameModelType.actionResponse ||
        gameModelType == GameModelType.joinGameResponse) {
      var gameId = gameIdFromJson(json);
      var gameController = server.games.find(gameId)!;
      game = gameController.game;
    }
    var model = gameModelFromJson(game, json);
    return await sendRequest(model);
  }

  @override
  Future<ResponseModel> sendRequest(GameModel model) async {
    return await server.handleRequest(model);
  }

  @override
  void init() {}
}

class LocalClientTransport implements GameTransport {
  final LocalServerTransport serverTransport;

  LocalClientTransport(this.serverTransport);

  @override
  Future<ResponseModel> sendRequest(GameModel model) async {
    var json = model.toJson();
    return await serverTransport.receiveLocalRequest(json);
    //return serverTransport.sendRequest(model);
  }

  @override
  void init() {}
}

class HttpServerTransport implements GameTransport {
  GameServer server;
  GameRequestCallback requestCallback;

  HttpServerTransport(this.server, this.requestCallback) : super() {
    // nothing here for now
  }

  @override
  Future<GameModel> sendRequest(GameModel model) => throw UnimplementedError();

  @override
  void init() {
    // create http server here
  }
}

class HttpClientTransport implements GameTransport {
  HttpClientTransport();

  @override
  Future<GameModel?> sendRequest(GameModel model) async {
    // send request over http and get reply
    return null;
  }

  @override
  void init() {
    // create http client here
  }
}
