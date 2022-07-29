import 'package:engine/engine.dart';

class VpAction extends GameAction {
  final int/*!*/ vp;

  VpAction(String player, this.vp, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.vp;

  @override
  bool matches(GameAction action) {
    if (action is VpAction) {
      return action.vp == vp;
    }
    return false;
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
