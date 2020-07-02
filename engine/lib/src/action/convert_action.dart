import 'package:engine/engine.dart';

class ConvertAction extends Action {
  final ResourceType source;
  final ResourceType destination;

  ConvertAction(Player player, this.source, this.destination) : super(ActionType.convert, player);
}

class RequestConvertAction extends Action {
  final ResourceType resourceType;

  RequestConvertAction(Player player, this.resourceType) : super(ActionType.requestConvert, player);
}

class DoubleConvertAction extends Action {
  final ResourceType source;

  DoubleConvertAction(Player player, this.source) : super(ActionType.doubleConvert, player);
}

class RequestDoubleConvertAction extends Action {
  final ResourceType resourceType;

  RequestDoubleConvertAction(Player player, this.resourceType) : super(ActionType.requestDoubleConvert, player);
}
