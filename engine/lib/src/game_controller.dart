import 'dart:convert';
import 'dart:math';

import 'package:engine/engine.dart';

class GameController {
  Game game;
  Random random;
  //List<List<Part>> startingPartDecks;
  //List<String> playerIds;

  String get gameId => game?.gameId ?? 'null';

  GameController() {
    random = Random();
  }

  void setupGame(List<String> playerIds, PlayerService playerService, String gameId) {
    var players = playerIds.toList();
    players.shuffle();
    game = Game(players, playerService, gameId);
    var startingPartDecks = List<List<Part>>(3);
    for (var i = 0; i < 3; ++i) {
      startingPartDecks[i] = <Part>[];
    }
    for (var part in game.allParts.values) {
      startingPartDecks[part.level].add(part);
    }
    for (var i = 0; i < 3; ++i) {
      startingPartDecks[i].shuffle();
    }
    // partDecks[2].removeRange(16, partDecks[2].length);
    game.assignStartingDecks(startingPartDecks);

    game.startGame();
    game.startNextTurn();
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{};
    ret['players'] = game.getPlayerIds();
    ret['l1'] = partListToString(game.partDecks[0].toList());
    ret['l2'] = partListToString(game.partDecks[1].toList());
    ret['l3'] = partListToString(game.partDecks[2].toList());
    ret['well'] = resourceListToString(game.well.toList());
    ret['game'] = game.toJson();

    return ret;
  }

  void loadGame(PlayerService playerService, String jsonString) {
    var json = jsonDecode(jsonString) as Map<String, dynamic>;

    var playerIds = listFromJson<String>(json);

    game = Game.fromJson(playerIds, playerService, json);

    game.changeStack = ChangeStack(); // will be discarded

    var startingPartDecks = List<List<Part>>(3);
    for (var i = 0; i < 3; ++i) {
      startingPartDecks[i] = <Part>[];
    }
    partStringToList(json['l1'] as String, (part) => startingPartDecks[0].add(part), game.allParts);
    partStringToList(json['l2'] as String, (part) => startingPartDecks[1].add(part), game.allParts);
    partStringToList(json['l3'] as String, (part) => startingPartDecks[2].add(part), game.allParts);
    game.assignStartingDecks(startingPartDecks);

    stringToResourceListState(json['well'] as String, game.well);
  }

  String getGameState() {
    return jsonEncode(game);
  }

  /// Restores game state from json string [src].  Used by the client to update.
  static Game restoreGame(List<String> players, PlayerService playerService, String src) {
    var json = jsonDecode(src) as Map<String, dynamic>;
    return Game.fromJson(players, playerService, json);
  }

  String getSaveString() {
    return jsonEncode(this);
  }
}
