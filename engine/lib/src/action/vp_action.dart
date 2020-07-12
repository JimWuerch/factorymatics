import 'package:engine/engine.dart';

class VpAction extends GameAction {
  final int vp;

  VpAction(String player, this.vp) : super(player);

  @override
  ActionType get actionType => ActionType.vp;

  @override
  bool matches(GameAction action) {
    return action is VpAction;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['vp'] = vp;
    return ret;
  }

  VpAction.fromJson(Game game, Map<String, dynamic> json)
      : vp = json['vp'] as int,
        super.fromJson(game, json);
}

// class RequestVpAction extends GameAction {
//   final int vp;

//   RequestVpAction(String player, this.vp) : super(player);

//   @override
//   ActionType get actionType => ActionType.requestVp;

//   @override
//   Map<String, dynamic> toJson() {
//     var ret = super.toJson();
//     ret['vp'] = vp;
//     return ret;
//   }

//   RequestVpAction.fromJson(Game game, Map<String, dynamic> json)
//       : vp = json['vp'] as int,
//         super.fromJson(game, json);
// }
