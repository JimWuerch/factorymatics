import 'package:engine/engine.dart';

class GameRequest {
  String auth;
  GameAction action;

  GameRequest(this.auth, this.action);

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{};

    ret['auth'] = auth;
    ret['action'] = action.toJson();

    return ret;
  }

  factory GameRequest.fromJson(Game game, Map<String, dynamic> json) {
    var auth = json['auth'] as String;
    var action = actionFromJson(game, json['action'] as Map<String, dynamic>);
    return GameRequest(auth, action);
  }
}
