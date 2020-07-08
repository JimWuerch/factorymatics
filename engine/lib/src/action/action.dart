import 'package:engine/engine.dart';

import 'acquire_action.dart';
import 'construct_action.dart';
import 'convert_action.dart';
import 'scavenge_action.dart';
import 'store_action.dart';
import 'vp_action.dart';

export 'acquire_action.dart';
export 'construct_action.dart';
export 'convert_action.dart';
export 'scavenge_action.dart';
export 'store_action.dart';
export 'vp_action.dart';

enum ActionType {
  store,
  construct,
  acquire,
  scavenge,
  convert,
  doubleConvert,
  mysteryMeat,
  vp,
  requestStore,
  requestConstruct,
  requestAcquire,
  requestScavenge,
  requestConvert,
  requestDoubleConvert,
  requestMysteryMeat,
  requestVp,
}

abstract class GameAction {
  ActionType get actionType;
  final String owner;
  String get message => 'action';

  GameAction(this.owner);

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
    case ActionType.scavenge:
      return ScavengeAction.fromJson(game, json);
    case ActionType.convert:
      return ConvertAction.fromJson(game, json);
    case ActionType.doubleConvert:
      return DoubleConvertAction.fromJson(game, json);
    case ActionType.mysteryMeat:
      return MysteryMeatAction.fromJson(game, json);
    case ActionType.vp:
      return VpAction.fromJson(game, json);
    case ActionType.requestStore:
      return RequestStoreAction.fromJson(game, json);
    case ActionType.requestConstruct:
      return RequestConstructAction.fromJson(game, json);
    case ActionType.requestAcquire:
      return RequestAcquireAction.fromJson(game, json);
    case ActionType.requestScavenge:
      return RequestScavengeAction.fromJson(game, json);
    case ActionType.requestConvert:
      return RequestConvertAction.fromJson(game, json);
    case ActionType.requestDoubleConvert:
      return RequestDoubleConvertAction.fromJson(game, json);
    case ActionType.requestMysteryMeat:
      return RequestMysteryMeatAction.fromJson(game, json);
    case ActionType.requestVp:
      return RequestVpAction.fromJson(game, json);
    default:
      throw InvalidOperationError('Unknown action: ${json['type'] as int}');
  }
}
