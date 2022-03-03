import 'package:engine/engine.dart';
import 'package:engine/src/ai/ai_player.dart';

Game game;

String player = 'p1';

void _createGame() {
  var playerService = PlayerService.createService();
  playerService.addPlayer(player, player);
  playerService.addPlayer('p2', 'p2');
  game = Game(<String>[player, 'p2'], playerService, '1');
  game.tmpName = 'test';
  game.createGame();
  var startingPartDecks = List<List<Part>>.filled(3, null);
  for (var i = 0; i < 3; ++i) {
    startingPartDecks[i] = <Part>[];
  }
  for (var part in game.allParts.values) {
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

void main() {
  _createGame();

  var ai = AiPlayer(game.players[0]);
  var ai2 = AiPlayer(game.players[1]);
  while (!game.currentTurn.gameEnded) {
    ai.takeTurn(game);
    ai2.takeTurn(game);
    for (var i = 0; i < 2; i++) {
      print('Score for ${game.players[i].id} is ${game.players[i].score} at round ${game.round}');
    }
  }
}
