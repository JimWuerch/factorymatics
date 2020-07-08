import 'package:engine/engine.dart';

import 'game_model.dart';

class CreateGameRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.createGameRequest;

  //final GameAction action;
  final String gameId;

  CreateGameRequest(String ownerId, this.gameId) : super('create', ownerId, 'createGame request');

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['gameId'] = gameId;
    return ret;
  }

  CreateGameRequest.fromJson(Map<String, dynamic> json)
      : gameId = json['gameId'] as String,
        super.fromJson(json);
}
