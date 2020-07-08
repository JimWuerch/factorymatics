import 'package:engine/engine.dart';

class StoreAction extends GameAction {
  final int index;

  StoreAction(String player, this.index) : super(player);

  @override
  ActionType get actionType => ActionType.store;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['index'] = index;
    return ret;
  }

  StoreAction.fromJson(Game game, Map<String, dynamic> json)
      : index = json['index'] as int,
        super.fromJson(game, json);
}

class RequestStoreAction extends GameAction {
  final int index;

  RequestStoreAction(String player, this.index) : super(player);

  @override
  ActionType get actionType => ActionType.requestStore;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['index'] = index;
    return ret;
  }

  RequestStoreAction.fromJson(Game game, Map<String, dynamic> json)
      : index = json['index'] as int,
        super.fromJson(game, json);
}
