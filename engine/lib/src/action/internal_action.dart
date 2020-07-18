import 'package:engine/engine.dart';

// InternalAction shouldn't be serialized.
abstract class InternalAction extends GameAction {
  InternalAction(String player) : super(player);

  @override
  ActionType get actionType => ActionType.internal;

  @override
  bool matches(GameAction action) {
    return action is InternalAction;
  }

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    return ret;
  }

  InternalAction.fromJson(Game game, Map<String, dynamic> json) : super.fromJson(game, json);
}

class FillMarketAction extends InternalAction {
  final ListState<Part> list;
  final Part part;

  FillMarketAction(String player, this.list, this.part) : super(player);
}

class FillResourceAction extends InternalAction {
  final ResourceType resource;

  FillResourceAction(String player, this.resource) : super(player);
}
