import 'package:engine/engine.dart';
import 'package:engine/src/action/convert_action.dart';
import 'package:engine/src/action/vp_action.dart';

abstract class Product {
  Product();
  GameAction produce(Game game, String player);
}

class MysteryMeatProduct extends Product {
  @override
  GameAction produce(Game game, String player) {
    return RequestMysteryMeatAction(player);
  }
}

class AcquireProduct extends Product {
  @override
  GameAction produce(Game game, String player) {
    return RequestAcquireAction(player);
  }
}

class ConvertProduct extends Product {
  final ResourceType source;
  final ResourceType dest;

  ConvertProduct(this.source, this.dest);

  @override
  GameAction produce(Game game, String player) {
    return RequestConvertAction(player, source, dest);
  }
}

class VpProduct extends Product {
  final int vp;

  VpProduct(this.vp);

  @override
  GameAction produce(Game game, String player) {
    return RequestVpAction(player, vp);
  }
}

class DoubleResourceProduct extends Product {
  final ResourceType resourceType;

  DoubleResourceProduct(this.resourceType);

  @override
  GameAction produce(Game game, String player) {
    return RequestDoubleConvertAction(player, resourceType);
  }
}
