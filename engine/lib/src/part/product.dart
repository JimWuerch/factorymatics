import 'package:engine/engine.dart';
import 'package:engine/src/action/convert_action.dart';
import 'package:engine/src/action/vp_action.dart';

abstract class Product {
  Product();
  GameAction produce(Game game, String player, Part producedBy);
}

class MysteryMeatProduct extends Product {
  @override
  GameAction produce(Game game, String player, Part producedBy) {
    return MysteryMeatAction(player, producedBy);
  }
}

class AcquireProduct extends Product {
  @override
  GameAction produce(Game game, String player, Part producedBy) {
    return AcquireAction(player, -1, producedBy);
  }
}

class ConvertProduct extends Product {
  final ResourceType source;
  final ResourceType dest;

  ConvertProduct(this.source, this.dest);

  @override
  GameAction produce(Game game, String player, Part producedBy) {
    return ConvertAction(player, source, ResourceType.any, producedBy);
  }
}

class VpProduct extends Product {
  final int vp;

  VpProduct(this.vp);

  @override
  GameAction produce(Game game, String player, Part producedBy) {
    return VpAction(player, vp, producedBy);
  }
}

class DoubleResourceProduct extends Product {
  final ResourceType resourceType;

  DoubleResourceProduct(this.resourceType);

  @override
  GameAction produce(Game game, String player, Part producedBy) {
    return DoubleConvertAction(player, resourceType, producedBy);
  }
}
