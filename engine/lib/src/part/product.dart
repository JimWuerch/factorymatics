import 'package:engine/engine.dart';
import 'package:engine/src/action/convert_action.dart';
import 'package:engine/src/action/vp_action.dart';

abstract class Product {
  Product();
  Action produce(Game game, Player player);
}

class MysteryMeatProduct extends Product {
  @override
  Action produce(Game game, Player player) {
    return RequestMysteryMeatAction(player);
  }
}

class AcquireProduct extends Product {
  @override
  Action produce(Game game, Player player) {
    return RequestAcquireAction(player);
  }
}

class ConvertProduct extends Product {
  final ResourceType resourceType;

  ConvertProduct(this.resourceType);

  @override
  Action produce(Game game, Player player) {
    return RequestConvertAction(player, resourceType);
  }
}

class VpProduct extends Product {
  final int vp;

  VpProduct(this.vp);

  @override
  Action produce(Game game, Player player) {
    return RequestVpAction(player, vp);
  }
}

class DoubleResourceProduct extends Product {
  final ResourceType resourceType;

  DoubleResourceProduct(this.resourceType);

  @override
  Action produce(Game game, Player player) {
    return RequestDoubleConvertAction(player, resourceType);
  }
}
