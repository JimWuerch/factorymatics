import 'package:engine/engine.dart';

class ScavengeAction extends GameAction {
  final GameAction action;

  ScavengeAction(String player, this.action) : super(player);

  @override
  ActionType get actionType => ActionType.acquire;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['action'] = action.toJson();
    return ret;
  }

  ScavengeAction._fromJsonHelper(Game game, Map<String, dynamic> json, this.action) : super.fromJson(game, json);

  factory ScavengeAction.fromJson(Game game, Map<String, dynamic> json) {
    var action = actionFromJson(game, json['action'] as Map<String, dynamic>);
    return ScavengeAction._fromJsonHelper(game, json, action);
  }
}

class RequestScavengeAction extends GameAction {
  final GameAction action;

  RequestScavengeAction(String player, this.action) : super(player);

  @override
  ActionType get actionType => ActionType.acquire;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['action'] = action.toJson();
    return ret;
  }

  RequestScavengeAction._fromJsonHelper(Game game, Map<String, dynamic> json, this.action) : super.fromJson(game, json);

  factory RequestScavengeAction.fromJson(Game game, Map<String, dynamic> json) {
    var action = actionFromJson(game, json['action'] as Map<String, dynamic>);
    return RequestScavengeAction._fromJsonHelper(game, json, action);
  }
}
