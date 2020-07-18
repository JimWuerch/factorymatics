import 'package:engine/engine.dart';

import 'game_model.dart';

class CreateGameRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.createGameRequest;

  CreateGameRequest(String gameId, String ownerId) : super(gameId, ownerId, 'createGame request');

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  CreateGameRequest.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
