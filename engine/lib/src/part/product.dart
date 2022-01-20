import 'package:engine/engine.dart';

enum ProductType { mysteryMeat, aquire, convert, vp, doubleResource, search, store, freeConstruct }

abstract class Product {
  final ProductType productType;
  Part part; // set in the part constructor
  final GameStateVar<bool> activated;

  Product(Game game, this.productType) : activated = GameStateVar(game, 'product:activated', false);

  GameAction produce(Game game, String player);
}

class MysteryMeatProduct extends Product {
  MysteryMeatProduct(Game game) : super(game, ProductType.mysteryMeat);

  @override
  GameAction produce(Game game, String player) {
    return MysteryMeatAction(player, this);
  }
}

class AcquireProduct extends Product {
  AcquireProduct(Game game) : super(game, ProductType.aquire);

  @override
  GameAction produce(Game game, String player) {
    return AcquireAction(player, -1, this);
  }
}

class ConvertProduct extends Product {
  final ResourceType source;
  final ResourceType dest;

  ConvertProduct(Game game, this.source, this.dest) : super(game, ProductType.convert);

  @override
  GameAction produce(Game game, String player) {
    return ConvertAction(player, source, ResourceType.any, this);
  }
}

class VpProduct extends Product {
  final int vp;

  VpProduct(Game game, this.vp) : super(game, ProductType.vp);

  @override
  GameAction produce(Game game, String player) {
    return VpAction(player, vp, this);
  }
}

class DoubleResourceProduct extends Product {
  final ResourceType resourceType;

  DoubleResourceProduct(Game game, this.resourceType) : super(game, ProductType.doubleResource);

  @override
  GameAction produce(Game game, String player) {
    return DoubleConvertAction(player, resourceType, this);
  }
}

class SearchProduct extends Product {
  SearchProduct(Game game) : super(game, ProductType.search);

  @override
  GameAction produce(Game game, String player) {
    throw UnimplementedError();
  }
}

class StoreProduct extends Product {
  StoreProduct(Game game) : super(game, ProductType.store);

  @override
  GameAction produce(Game game, String player) {
    throw UnimplementedError();
  }
}

class FreeConstructProduct extends Product {
  final int level;

  FreeConstructProduct(Game game, this.level) : super(game, ProductType.freeConstruct);

  @override
  GameAction produce(Game game, String player) {
    throw UnimplementedError();
  }
}
