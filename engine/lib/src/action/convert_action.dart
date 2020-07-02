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
