import 'package:engine/engine.dart';

import 'acquire_action.dart';
import 'construct_action.dart';
import 'convert_action.dart';
import 'search_action.dart';
import 'select_action_action.dart';
import 'store_action.dart';
import 'vp_action.dart';

export 'acquire_action.dart';
export 'construct_action.dart';
export 'convert_action.dart';
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

  GameAction(this.owner);

  /// Returns true if [action] is a similar action
  ///
  /// This is used to match an action with the list of available actions.
  /// For example, a convert action matches if the source resource is the same
  /// for both this and [action]
  bool matches(GameAction action);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': ActionType.values.indexOf(actionType),
        'owner': owner,
      };

  GameAction.fromJson(Game game, Map<String, dynamic> json)
      : owner = game.playerService.getPlayer(json['owner'] as String).playerId;
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
