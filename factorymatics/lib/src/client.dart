import 'package:engine/engine.dart';
import 'server.dart';

abstract class Client {
  Stream<GameAction> get inbound;
  void postAction(GameAction action);
  Future<Game> createGame(int gameId);
}

class LocalClient extends Client {
  final LocalServer server;
  LocalClient() : server = LocalServer();

  @override
  Stream<GameAction> get inbound => server.actions;

  @override
  void postAction(GameAction action) {
    server.postAction(action);
  }

  @override
  Future<Game> createGame(int id) async {
    return server.createGame(id);
  }
}
