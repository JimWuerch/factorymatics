import 'package:engine/engine.dart';

import 'game_model.dart';

class CreateGameResponse extends ResponseModel {
  final List<String> players;

  CreateGameResponse(Game game, String owner, String desc, ResponseCode code)
      : players = game.getPlayerNames(),
        super(game.gameId, owner, 'createGame response', code);

  @override
  GameModelType get modelType => GameModelType.createGameResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['players'] = players;
    return ret;
  }

  CreateGameResponse._fromJsonHelper(this.players, Map<String, dynamic> json) : super.fromJson(json);

  factory CreateGameResponse.fromJson(Map<String, dynamic> json) {
    var players = listFromJson<String>(json);
    return CreateGameResponse._fromJsonHelper(players, json);
  }
}
