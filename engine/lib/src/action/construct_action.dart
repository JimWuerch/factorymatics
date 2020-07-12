import 'package:engine/engine.dart';

class ConstructAction extends GameAction {
  final Part part;
  final List<ResourceType> payment;

  ConstructAction(String player, this.part, this.payment) : super(player);

  @override
  ActionType get actionType => ActionType.construct;

  @override
  bool matches(GameAction action) {
    return action is ConstructAction;
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

// class RequestConstructAction extends GameAction {
//   final Part part;

//   RequestConstructAction(String player, this.part) : super(player);

//   @override
//   ActionType get actionType => ActionType.requestConstruct;

//   @override
//   Map<String, dynamic> toJson() {
//     var ret = super.toJson();
//     ret['part'] = part.id;
//     return ret;
//   }

//   RequestConstructAction.fromJson(Game game, Map<String, dynamic> json)
//       : part = game.allParts[json['part'] as String],
//         super.fromJson(game, json);
// }
