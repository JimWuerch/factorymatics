import 'package:engine/engine.dart';

// import 'acquire_action.dart';
// import 'construct_action.dart';
// import 'convert_action.dart';
// import 'search_action.dart';
// import 'select_action_action.dart';
// import 'store_action.dart';
// import 'vp_action.dart';

export 'acquire_action.dart';
export 'construct_action.dart';
export 'convert_action.dart';
export 'game_mode_action.dart';
export 'internal_action.dart';
export 'search_action.dart';
export 'select_action_action.dart';
export 'store_action.dart';
export 'vp_action.dart';

enum ActionType {
  store,
  construct,
  acquire,
  search,
  convert,
  doubleConvert,
  mysteryMeat,
  vp,
  selectAction,
  gameMode,
  internal,
  searchActionResult,
  requestAcquire,
  searchDeclined,
  requestSearch,
  requestConstructL1,
  requestStore,
  // requestStore,
  // requestConstruct,
  // requestAcquire,
  // requestSearch,
  // requestConvert,
  // requestDoubleConvert,
  // requestMysteryMeat,
  // requestVp,
}

abstract class GameAction {
  ActionType get actionType;
  final String owner;
  String get message => 'action';

  // for actions that are the result of part activations
  Product producedBy;

  GameAction(this.owner, [this.producedBy]);

  /// Returns true if [action] is a similar action
  ///
  /// This is used to match an action with the list of available actions.
  /// For example, a convert action matches if the source resource is the same
  /// for both this and [action]
  bool matches(GameAction action);

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{
      'type': ActionType.values.indexOf(actionType),
      'owner': owner,
    };
    if (producedBy != null) {
      ret['part'] = producedBy.part.id;
      ret['pi'] = producedBy.prodIndex;
    }
    return ret;
  }

  GameAction.fromJson(Game game, Map<String, dynamic> json)
      : owner = game.playerService.getPlayer(json['owner'] as String).playerId {
    if (json.containsKey('part')) {
      var part = game.allParts[json['part'] as String];
      if (json.containsKey('pi')) {
        producedBy = part.products[json['pi'] as int];
      }
    }
  }
}

GameAction actionFromJson(Game game, Map<String, dynamic> json) {
  switch (ActionType.values[json['type'] as int]) {
    case ActionType.store:
      return StoreAction.fromJson(game, json);
    case ActionType.construct:
      return ConstructAction.fromJson(game, json);
    case ActionType.acquire:
      return AcquireAction.fromJson(game, json);
    case ActionType.search:
      return SearchAction.fromJson(game, json);
    case ActionType.convert:
      return ConvertAction.fromJson(game, json);
    case ActionType.doubleConvert:
      return DoubleConvertAction.fromJson(game, json);
    case ActionType.mysteryMeat:
      return MysteryMeatAction.fromJson(game, json);
    case ActionType.vp:
      return VpAction.fromJson(game, json);
    case ActionType.selectAction:
      return SelectActionAction.fromJson(game, json);
    case ActionType.searchActionResult:
      return SearchActionResult.fromJson(game, json);
    case ActionType.gameMode:
      return GameModeAction.fromJson(game, json);
    case ActionType.requestAcquire:
      return RequestAcquireAction.fromJson(game, json);
    case ActionType.searchDeclined:
      return SearchDeclinedAction.fromJson(game, json);
    case ActionType.requestSearch:
      return RequestSearchAction.fromJson(game, json);
    case ActionType.requestConstructL1:
      return RequestConstructL1Action.fromJson(game, json);
    // case ActionType.requestStore:
    //   return RequestStoreAction.fromJson(game, json);
    // case ActionType.requestConstruct:
    //   return RequestConstructAction.fromJson(game, json);
    // case ActionType.requestAcquire:
    //   return RequestAcquireAction.fromJson(game, json);
    // case ActionType.requestSearch:
    //   return RequestSearchAction.fromJson(game, json);
    // case ActionType.requestConvert:
    //   return RequestConvertAction.fromJson(game, json);
    // case ActionType.requestDoubleConvert:
    //   return RequestDoubleConvertAction.fromJson(game, json);
    // case ActionType.requestMysteryMeat:
    //   return RequestMysteryMeatAction.fromJson(game, json);
    // case ActionType.requestVp:
    //   return RequestVpAction.fromJson(game, json);
    default:
      throw InvalidOperationError('Unknown action: ${json['type'] as int}');
  }
}
