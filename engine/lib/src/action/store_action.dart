import 'package:engine/engine.dart';

class StoreAction extends GameAction {
  final Part part;

  StoreAction(String player, this.part, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.store;

  @override
  bool matches(GameAction action) {
    if (action is StoreAction) {
      return action.part == part;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['part'] = part.id;
    return ret;
  }

  StoreAction.fromJson(Game game, Map<String, dynamic> json)
      : part = game.allParts[json['part'] as String],
        super.fromJson(game, json);
}
