import 'package:engine/engine.dart';

class VpAction extends Action {
  final int vp;

  VpAction(Player player, this.vp) : super(ActionType.vp, player);
}

class RequestVpAction extends Action {
  final int vp;

  RequestVpAction(Player player, this.vp) : super(ActionType.requestVp, player);
}
