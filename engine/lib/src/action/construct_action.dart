import 'package:engine/engine.dart';

class ConstructAction extends GameAction {
  final Part part;
  final List<ResourceType> payment;
  final List<GameAction> convertersUsed;

  ConstructAction(String player, this.part, this.payment, Product producedBy, this.convertersUsed)
      : super(player, producedBy);

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
    if (convertersUsed != null) {
      ret['cv'] = convertersUsed.map<Map<String, dynamic>>((e) => e.toJson()).toList();
    }
    return ret;
  }

  ConstructAction._fromJsonHelper(Game game, this.part, this.payment, this.convertersUsed, Map<String, dynamic> json)
      : super.fromJson(game, json);

  factory ConstructAction.fromJson(Game game, Map<String, dynamic> json) {
    var part = game.allParts[json['part'] as String];
    var payment = stringToResourceList(json['payment'] as String);
    var item = json['cv'] as List<dynamic>;
    List<GameAction> convertersUsed;
    if (json.containsKey('cv')) {
      convertersUsed =
          item.map<GameAction>((dynamic json) => actionFromJson(game, json as Map<String, dynamic>)).toList();
    }
    //super.fromJson(game, json);
    return ConstructAction._fromJsonHelper(game, part, payment, convertersUsed, json);
  }
}
