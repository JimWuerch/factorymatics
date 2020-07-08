import 'package:engine/engine.dart';

import 'game_server.dart';

typedef GameRequestCallback = void Function(GameModel model);

abstract class GameTransport {
  void init();
  Future<GameModel> sendRequest(GameModel model);
}

class LocalServerTransport implements GameTransport {
  GameServer server;

  LocalServerTransport(this.server);

  @override
  Future<GameModel> sendRequest(GameModel model) async {
    return server.handleRequest(model);
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
  Future<GameModel> sendRequest(GameModel model) async {
    // send request over http and get reply
    return null;
  }

  @override
  void init() {
    // create http client here
  }
}
