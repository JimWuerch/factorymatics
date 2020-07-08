import 'package:engine/engine.dart';

class GamePageModel {
  Game game;
  PlayerService playerService;
  String gameId;

  GamePageModel(this.playerService, this.gameId);

  void init() {
    game = Game(playerService, gameId);
  }
}
