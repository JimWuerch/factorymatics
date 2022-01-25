import 'package:engine/engine.dart';
import 'package:server/server.dart';
import 'server.dart';

abstract class Client {
  Stream<GameAction> get inbound;
  Future<ResponseModel> postAction(Game game, GameAction action);
  List<Future<ResponseModel>> postActionList(Game game, List<GameAction> actions);
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
  List<Future<ResponseModel>> postActionList(Game game, List<GameAction> actions) {
    var ret = <Future<ResponseModel>>[];
    for (var action in actions) {
      ret.add(postRequest(ActionRequest(game, owner, action)));
    }
    return ret;
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
