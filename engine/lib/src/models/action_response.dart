import 'package:engine/engine.dart';

class ActionResponse extends ResponseModel {
  @override
  GameModelType get modelType => GameModelType.actionResponse;

  ActionResponse(Game game, String owner, ResponseCode code) : super(game.gameId, owner, 'action response', code);

  Map<String, dynamic> toJson() => super.toJson();
  ActionResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
