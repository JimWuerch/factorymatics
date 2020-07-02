import 'package:engine/engine.dart';

class ConstructAction extends Action {
  final Part part;

  ConstructAction(Player player, this.part) : super(ActionType.construct, player);
}

class RequestConstructAction extends Action {
  final Part part;

  RequestConstructAction(Player player, this.part) : super(ActionType.requestConstruct, player);
}
