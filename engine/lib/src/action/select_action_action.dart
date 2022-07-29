import 'package:engine/engine.dart';

class SelectActionAction extends GameAction {
  final ActionType/*!*/ selectedAction;

  SelectActionAction(String player, this.selectedAction) : super(player);

  @override
  ActionType get actionType => ActionType.selectAction;

  @override
  bool matches(GameAction action) {
    if (action is SelectActionAction) {
      return action.selectedAction == selectedAction;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['selected'] = ActionType.values.indexOf(selectedAction);
    return ret;
  }

  SelectActionAction.fromJson(Game game, Map<String, dynamic> json)
      : selectedAction = ActionType.values[json['selected'] as int],
        super.fromJson(game, json);

  @override
  String toString() {
    return 'SelectActionAction:$selectedAction';
  }
}
