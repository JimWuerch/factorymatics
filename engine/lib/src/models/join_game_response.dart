import 'package:engine/engine.dart';

class JoinGameResponse extends ResponseModel {
  final String gameState;

  JoinGameResponse(Game game, String owner, String desc, ResponseCode code, this.gameState)
      : super(game.gameId, owner, 'joinGame response', code);

  @override
  GameModelType get modelType => GameModelType.joinGameResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['gameState'] = gameState;
    return ret;
  }

  JoinGameResponse.fromJson(Game game, Map<String, dynamic> json)
      : gameState = json['gameState'] as String,
        super.fromJson(json);
}
