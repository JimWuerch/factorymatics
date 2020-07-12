import 'package:engine/engine.dart';

class SearchAction extends GameAction {
  final GameAction action;

  SearchAction(String player, this.action) : super(player);

  @override
  ActionType get actionType => ActionType.acquire;

  @override
  bool matches(GameAction action) {
    return action is SearchAction;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['action'] = action.toJson();
    return ret;
  }

  SearchAction._fromJsonHelper(Game game, Map<String, dynamic> json, this.action) : super.fromJson(game, json);

  factory SearchAction.fromJson(Game game, Map<String, dynamic> json) {
    var action = actionFromJson(game, json['action'] as Map<String, dynamic>);
    return SearchAction._fromJsonHelper(game, json, action);
  }
}

// class RequestSearchAction extends GameAction {
//   final GameAction action;

//   RequestSearchAction(String player, this.action) : super(player);

//   @override
//   ActionType get actionType => ActionType.acquire;

//   @override
//   Map<String, dynamic> toJson() {
//     var ret = super.toJson();
//     ret['action'] = action.toJson();
//     return ret;
//   }

//   RequestSearchAction._fromJsonHelper(Game game, Map<String, dynamic> json, this.action) : super.fromJson(game, json);

//   factory RequestSearchAction.fromJson(Game game, Map<String, dynamic> json) {
//     var action = actionFromJson(game, json['action'] as Map<String, dynamic>);
//     return RequestSearchAction._fromJsonHelper(game, json, action);
//   }
// }
