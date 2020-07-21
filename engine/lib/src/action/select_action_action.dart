import 'package:engine/engine.dart';

class SelectActionAction extends GameAction {
  final ActionType selectedAction;

  SelectActionAction(String player, this.selectedAction) : super(player);

  @override
  ActionType get actionType => ActionType.selectAction;

  @override
  bool matches(GameAction action) {
    return (action as SelectActionAction)?.selectedAction == selectedAction;
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
}
