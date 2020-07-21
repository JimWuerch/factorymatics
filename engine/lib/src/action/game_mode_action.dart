import 'package:engine/engine.dart';

enum GameModeType { startGame, endGame, startTurn, endTurn }

class GameModeAction extends GameAction {
  final GameModeType mode;

  GameModeAction(String player, this.mode) : super(player);

  @override
  ActionType get actionType => ActionType.gameMode;

  @override
  bool matches(GameAction action) {
    return (action as GameModeAction)?.mode == mode;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['mode'] = GameModeType.values.indexOf(mode);
    return ret;
  }

  GameModeAction.fromJson(Game game, Map<String, dynamic> json)
      : mode = GameModeType.values[json['mode'] as int],
        super.fromJson(game, json);
}
