import 'package:engine/engine.dart';

class ConstructAction extends GameAction {
  final Part part;

  ConstructAction(String player, this.part) : super(player);

  @override
  ActionType get actionType => ActionType.construct;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['part'] = part.id;
    return ret;
  }

  ConstructAction.fromJson(Game game, Map<String, dynamic> json)
      : part = game.allParts[json['part'] as String],
        super.fromJson(game, json);
}

class RequestConstructAction extends GameAction {
  final Part part;

  RequestConstructAction(String player, this.part) : super(player);

  @override
  ActionType get actionType => ActionType.requestConstruct;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['part'] = part.id;
    return ret;
  }

  RequestConstructAction.fromJson(Game game, Map<String, dynamic> json)
      : part = game.allParts[json['part'] as String],
        super.fromJson(game, json);
}
