import 'package:engine/engine.dart';

class SearchAction extends GameAction {
  final int level;

  SearchAction(String player, this.level, [Product producedBy]) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.search;

  @override
  bool matches(GameAction action) {
    if (action is SearchAction) {
      return action.level == level;
    }
    return false;
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

  SearchActionResult(String player, this.parts, [Product producedBy]) : super(player, producedBy);

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

/// User did a search and decided (or couldn't) not to build or store anything.
class SearchDeclinedAction extends GameAction {
  SearchDeclinedAction(String player, [Product producedBy]) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.searchDeclined;

  @override
  bool matches(GameAction action) {
    return action is SearchDeclinedAction;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  SearchDeclinedAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}

class RequestSearchAction extends GameAction {
  RequestSearchAction(String player, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.requestSearch;

  @override
  bool matches(GameAction action) {
    // we match all RequestSearchAction
    return action is RequestSearchAction;
  }

  RequestSearchAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}
