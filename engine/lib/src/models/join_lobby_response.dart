import 'package:engine/engine.dart';

class JoinLobbyResponse extends ResponseModel {
  JoinLobbyResponse(String gameId, String owner, ResponseCode code) : super(gameId, owner, 'joinLobby response', code);

  @override
  GameModelType get modelType => GameModelType.joinLobbyResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  JoinLobbyResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
