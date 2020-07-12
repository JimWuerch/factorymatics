import 'package:engine/engine.dart';

class StoreAction extends GameAction {
  final Part part;

  StoreAction(String player, this.part) : super(player);

  @override
  ActionType get actionType => ActionType.store;

  @override
  bool matches(GameAction action) {
    return action is StoreAction;
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

// class RequestStoreAction extends GameAction {
//   final int index;

//   RequestStoreAction(String player, this.index) : super(player);

//   @override
//   ActionType get actionType => ActionType.requestStore;

//   @override
//   Map<String, dynamic> toJson() {
//     var ret = super.toJson();
//     ret['index'] = index;
//     return ret;
//   }

//   RequestStoreAction.fromJson(Game game, Map<String, dynamic> json)
//       : index = json['index'] as int,
//         super.fromJson(game, json);
// }
