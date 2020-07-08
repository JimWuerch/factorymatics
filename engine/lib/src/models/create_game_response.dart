import 'package:engine/engine.dart';

import 'game_model.dart';

class CreateGameResponse extends GameModel {
  final String gameId;
  final List<String> players;

  CreateGameResponse(Game game, String owner, String desc, this.gameId, this.players)
      : super(game.gameId, owner, 'createGame response');

  @override
  GameModelType get modelType => GameModelType.createGameResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['gameIndex'] = gameId;
    ret['players'] = players;
    return ret;
  }

  CreateGameResponse.fromJson(Map<String, dynamic> json)
      : gameId = json['gameId'] as String,
        players = listFromJson<String>(json),
        super.fromJson(json);
}
