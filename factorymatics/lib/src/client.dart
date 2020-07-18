import 'package:engine/engine.dart';
import 'package:server/server.dart';
import 'server.dart';

abstract class Client {
  Stream<GameAction> get inbound;
  Future<ResponseModel> postAction(Game game, GameAction action);
  Future<ResponseModel> postRequest(GameModel model);
  //Future<bool> createGame(String gameId);
}

class LocalClient extends Client {
  final LocalServer server;
  final LocalClientTransport clientTransport;
  final String owner;

  LocalClient._create(this.server, this.owner, this.clientTransport);

  factory LocalClient(String owner) {
    var server = LocalServer();
    var clientTransport = LocalClientTransport(server.transport);

    server.server.createPlayer('bob', 'id1');

    return LocalClient._create(server, owner, clientTransport);
  }

  @override
  Stream<GameAction> get inbound => server.actions;

  @override
  Future<ResponseModel> postAction(Game game, GameAction action) {
    return postRequest(ActionRequest(game, owner, action));
  }

  @override
  Future<ResponseModel> postRequest(GameModel model) {
    return clientTransport.sendRequest(model);
  }

  // @override
  // Future<bool> createGame(String id) async {
  //   return server.createGame(id);
  // }
}
