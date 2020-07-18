import 'package:engine/engine.dart';

class JoinGameRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.joinGameRequest;

  // the turn index the joiner knows about. The game will replay all the turns that are newer than this index to the joiner
  //final int turnIndex;

  JoinGameRequest(String gameId, String ownerId) : super(gameId, ownerId, 'joinGame request');

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  JoinGameRequest.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
