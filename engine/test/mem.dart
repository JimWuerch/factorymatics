import 'package:engine/engine.dart';
import 'package:engine/src/ai/ai_player.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:args/args.dart';

Game game;

String player = 'p1';

void _createGame() {
  var playerService = PlayerService.createService();
  playerService.addPlayer(player, player);
  //playerService.addPlayer('p2', 'p2');
  //game = Game(<String>[player, 'p2'], playerService, '1');
  game = Game(<String>[player], playerService, '1');
  game.tmpName = 'test';
  game.createGame();
  var startingPartDecks = List<List<Part>>.filled(3, null);
  for (var i = 0; i < 3; ++i) {
    startingPartDecks[i] = <Part>[];
  }
  for (var part in allParts.values) {
    if (part.level != -1) {
      // initial part is lvl -1
      startingPartDecks[part.level].add(part);
    }
  }
  for (var i = 0; i < 3; ++i) {
    startingPartDecks[i].shuffle();
  }
  startingPartDecks[2].removeRange(16, startingPartDecks[2].length);
  game.assignStartingDecks(startingPartDecks);
  game.startGame();
  game.startNextTurn();
  //game.testMode = true;
}

int gameCount = 0;
Game _duplicateGame(Game game) {
  var gc = GameController();
  gc.game = game;
  var g = gc.gameFromJson(game.playerService, gc.toJson());
  gc.game = null;
  g.inSimulation = true;
  g.nextObjectId = ++gameCount;
  return g;
}

class Data {
  int count;
  double bonus;

  Data(this.count, this.bonus);
}

void main(List<String> arguments) async {
  var cards = <String, Data>{};
  var games = 0;
  var numberFormat = NumberFormat('0000000', "en_US");

  final outputFile = arguments.isEmpty ? 'card_data.txt' : arguments[0];

  while (true) {
    _createGame();
    var ai = AiPlayer(game.players[0]);
//    var ai2 = AiPlayer(game.players[1]);

    while (!game.currentTurn.gameEnded) {
      ai.takeTurn(game);
      //ai2.takeTurn(game);
      for (var i = 0; i < game.players.length; i++) {
        print('Score for ${game.players[i].id} is ${game.players[i].score} at round ${game.round}');
      }
    }
    games++;
    for (var partList in game.players[0].parts.values) {
      for (var part in partList) {
        var bonus = game.players[0].score.toDouble() / game.round - 1;
        if (bonus < 0.0) {
          bonus = 0.0;
        }
        if (!cards.containsKey(part.id)) {
          cards[part.id] = Data(1, bonus);
        } else {
          cards[part.id].count++;
          cards[part.id].bonus += bonus;
        }
      }
    }
    var list = <String>[];
    for (var card in cards.entries) {
      if (card.key != "0") {
        list.add('${numberFormat.format(card.value.count)}:${card.key}:${card.value.bonus}');
      }
    }
    list.sort();
    var f = File(outputFile).openWrite();
    for (var l in list) {
      print(l);
      f.writeln(l);
    }
    await f.close();
    print('Game $games complete');
  }
}
