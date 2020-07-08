import 'package:engine/engine.dart';

class GameStore {
  // for now just put in a Map
  // later use sembast
  Map<String, Game> games;

  GameStore() {
    games = <String, Game>{};
  }

  Game find(String gameId) {
    return games[gameId];
  }

  void store(Game game) {
    games[game.gameId] = game;
  }

  void delete(String gameId) {
    if (games.containsKey(gameId)) {
      games.remove(gameId);
    }
  }
}
