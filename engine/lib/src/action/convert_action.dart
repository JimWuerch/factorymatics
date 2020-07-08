import 'package:engine/engine.dart';

class ConvertAction extends GameAction {
  final ResourceType source;
  final ResourceType destination;

  ConvertAction(String player, this.source, this.destination) : super(player);

  @override
  ActionType get actionType => ActionType.convert;

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

class RequestConvertAction extends GameAction {
  final ResourceType source;
  final ResourceType destination;

  RequestConvertAction(String player, this.source, this.destination) : super(player);

  @override
  ActionType get actionType => ActionType.convert;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['s'] = ResourceType.values.indexOf(source);
    ret['d'] = ResourceType.values.indexOf(destination);
    return ret;
  }

  RequestConvertAction.fromJson(Game game, Map<String, dynamic> json)
      : source = ResourceType.values[json['s'] as int],
        destination = ResourceType.values[json['d'] as int],
        super.fromJson(game, json);
}

class DoubleConvertAction extends GameAction {
  final ResourceType source;

  DoubleConvertAction(String player, this.source) : super(player);

  @override
  ActionType get actionType => ActionType.doubleConvert;

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

class RequestDoubleConvertAction extends GameAction {
  final ResourceType resourceType;

  RequestDoubleConvertAction(String player, this.resourceType) : super(player);

  @override
  ActionType get actionType => ActionType.requestDoubleConvert;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['r'] = ResourceType.values.indexOf(resourceType);
    return ret;
  }

  RequestDoubleConvertAction.fromJson(Game game, Map<String, dynamic> json)
      : resourceType = ResourceType.values[json['r'] as int],
        super.fromJson(game, json);
}
