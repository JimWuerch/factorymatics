import 'package:engine/engine.dart';
import 'package:server/server.dart';
import 'server.dart';

enum ConnectionStates { disconnected, connecting, connected }

abstract class Client {
  ConnectionStates connectionState;
  Stream<GameAction> get inbound;
  Future<ResponseModel> postAction(Game game, GameAction action);
  List<Future<ResponseModel>> postActionList(Game game, List<GameAction> actions);
  Future<ResponseModel> postRequest(GameModel model);
  //Future<bool> createGame(String gameId);

  Client() : connectionState = ConnectionStates.disconnected;
}

class LocalClient extends Client {
  final LocalServer server;
  final LocalClientTransport clientTransport;
  //final String owner;

  LocalClient._create(this.server, this.clientTransport) : super();

  factory LocalClient(List<String> players) {
    var server = LocalServer();
    var clientTransport = LocalClientTransport(server.transport);

    for (var element in players) {
      server.server.createPlayer(element, element);
    }
    //server.server.createPlayer('bob', 'id1');

    return LocalClient._create(server, clientTransport);
  }

  @override
  Stream<GameAction> get inbound => server.actions;

  @override
  Future<ResponseModel> postAction(Game game, GameAction action) async {
    return await postRequest(ActionRequest(game, action));
  }

  @override
  List<Future<ResponseModel>> postActionList(Game game, List<GameAction> actions) {
    var ret = <Future<ResponseModel>>[];
    for (var action in actions) {
      ret.add(postRequest(ActionRequest(game, action)));
    }
    return ret;
  }

  @override
  Future<ResponseModel> postRequest(GameModel model) async {
    return await clientTransport.sendRequest(model);
  }

  // @override
  // Future<bool> createGame(String id) async {
  //   return server.createGame(id);
  // }
}
