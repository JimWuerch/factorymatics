import 'package:engine/engine.dart';

class StoreAction extends GameAction {
  final Part part;

  StoreAction(String player, this.part, Part producedBy) : super(player, producedBy?.id);

  @override
  ActionType get actionType => ActionType.store;

  @override
  bool matches(GameAction action) {
    return (action as StoreAction)?.part == part;
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
