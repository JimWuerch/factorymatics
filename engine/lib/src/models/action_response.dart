import 'package:engine/engine.dart';

class ActionResponse extends ResponseModel {
  @override
  GameModelType get modelType => GameModelType.actionResponse;

  // some actions need to send data back to the client for efficiency
  final GameAction action;

  ActionResponse(String gameId, String owner, ResponseCode code, this.action)
      : super(gameId, owner, 'action response', code);

  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    if (action != null) {
      ret['action'] = action.toJson();
    }
    return ret;
  }

  ActionResponse._fromJsonHelper(this.action, Map<String, dynamic> json) : super.fromJson(json);

  factory ActionResponse.fromJson(Game game, Map<String, dynamic> json) {
    GameAction action;
    if (json.containsKey('action')) {
      action = actionFromJson(game, json);
    }
    return ActionResponse._fromJsonHelper(action, json);
  }
}
