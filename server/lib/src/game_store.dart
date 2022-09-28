import 'package:engine/engine.dart';

class GameLobby {
  String gameId;
  GameController? game;
  late List<Player> players;
  Player owner;

  GameLobby(this.gameId, this.owner) {
    players = <Player>[];
    players.add(owner);
  }
}

class GameStore {
  // for now just put in a Map
  // later use sembast
  final Map<String?, GameLobby> _games;
  int _nextGameIndex = 0;

  GameStore() : _games = <String?, GameLobby>{};

  GameController? find(String gameId) {
    return _games[gameId]!.game;
  }

  List<Player> findPlayers(String gameId) {
    return _games[gameId]!.players;
  }

  GameLobby createLobby(Player owner) {
    // TODO: id should be GUID
    var gameId = (_nextGameIndex++).toString();
    var lobby = GameLobby(gameId, owner);
    //lobby.gameId = (_nextGameIndex++).toString();
    _games[lobby.gameId] = lobby;
    return lobby;
  }

  // ignore: use_setters_to_change_properties
  bool store(GameController game) {
    if (!_games.containsKey(game.gameId)) {
      return false;
    }
    _games[game.gameId]!.game = game;
    return true;
  }

  bool addPlayer(String gameId, Player player) {
    if (!_games.containsKey(gameId)) {
      return false;
    }
    _games[gameId]!.players.add(player);
    return true;
  }

  void delete(String gameId) {
    if (_games.containsKey(gameId)) {
      _games.remove(gameId);
    }
  }
}
