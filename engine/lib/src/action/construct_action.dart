import 'package:engine/engine.dart';

class ConstructAction extends GameAction {
  final Part part;
  final List<ResourceType> payment;

  ConstructAction(String player, this.part, this.payment, Part producedBy) : super(player, producedBy?.id);

  @override
  ActionType get actionType => ActionType.construct;

  @override
  bool matches(GameAction action) {
    if (action is ConstructAction) {
      return action.part.id == part.id;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['part'] = part.id;
    if (payment != null) {
      ret['payment'] = resourceListToString(payment);
    }
    return ret;
  }

  ConstructAction.fromJson(Game game, Map<String, dynamic> json)
      : part = game.allParts[json['part'] as String],
        payment = stringToResourceList(json['payment'] as String),
        super.fromJson(game, json);
}
