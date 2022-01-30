import 'package:engine/engine.dart';

class ActionRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.actionRequest;

  final GameAction action;

  ActionRequest(Game game, this.action) : super(game.gameId, action.owner, action.message);

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['action'] = action.toJson();
    return ret;
  }

  ActionRequest.fromJson(Game game, Map<String, dynamic> json)
      : action = actionFromJson(game, json['action'] as Map<String, dynamic>),
        super.fromJson(json);
}
