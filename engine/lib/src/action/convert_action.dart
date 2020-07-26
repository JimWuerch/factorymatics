import 'package:engine/engine.dart';

class ConvertAction extends GameAction {
  final ResourceType source;
  final ResourceType destination;

  ConvertAction(String player, this.source, this.destination, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.convert;

  @override
  bool matches(GameAction action) {
    if (action is ConvertAction) {
      return action.source == source;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['s'] = ResourceType.values.indexOf(source);
    ret['d'] = ResourceType.values.indexOf(destination);
    return ret;
  }

  ConvertAction.fromJson(Game game, Map<String, dynamic> json)
      : source = ResourceType.values[json['s'] as int],
        destination = ResourceType.values[json['d'] as int],
        super.fromJson(game, json);
}

class DoubleConvertAction extends GameAction {
  final ResourceType source;

  DoubleConvertAction(String player, this.source, Product producedBy) : super(player, producedBy);

  @override
  ActionType get actionType => ActionType.doubleConvert;

  @override
  bool matches(GameAction action) {
    return (action as DoubleConvertAction)?.source == source;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['s'] = ResourceType.values.indexOf(source);
    return ret;
  }

  DoubleConvertAction.fromJson(Game game, Map<String, dynamic> json)
      : source = ResourceType.values[json['s'] as int],
        super.fromJson(game, json);
}
