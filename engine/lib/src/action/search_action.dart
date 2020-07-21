import 'package:engine/engine.dart';

class SearchAction extends GameAction {
  final int level;

  SearchAction(String player, this.level) : super(player);

  @override
  ActionType get actionType => ActionType.search;

  @override
  bool matches(GameAction action) {
    return (action as SearchAction)?.level == level;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['level'] = level;
    return ret;
  }

  SearchAction.fromJson(Game game, Map<String, dynamic> json)
      : level = json['level'] as int,
        super.fromJson(game, json);
}

class SearchActionResult extends GameAction {
  final List<String> parts;

  SearchActionResult(String player, this.parts) : super(player);

  @override
  ActionType get actionType => ActionType.searchActionResult;

  @override
  bool matches(GameAction action) {
    return false; // don't call this
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['parts'] = parts;
    return ret;
  }

  SearchActionResult.fromJson(Game game, Map<String, dynamic> json)
      : parts = listFromJson<String>(json['parts']),
        super.fromJson(game, json);
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
