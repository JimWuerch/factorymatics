import 'package:engine/engine.dart';

class CreateLobbyResponse extends ResponseModel {
  CreateLobbyResponse(String gameId, String owner, ResponseCode code)
      : super(gameId, owner, 'createLobby response', code);

  @override
  GameModelType get modelType => GameModelType.createLobbyResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  CreateLobbyResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
