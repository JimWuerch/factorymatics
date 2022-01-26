import 'package:engine/engine.dart';

enum ProductType { mysteryMeat, aquire, convert, vp, doubleResource, search, store, freeConstruct, spend }

abstract class Product {
  final ProductType productType;
  Part part; // set in the part constructor
  final GameStateVar<bool> activated;

  Product(Game game, this.productType) : activated = GameStateVar(game, 'product:activated', false);

  GameAction produce(Game game, String player);
}

abstract class ConverterBaseProduct extends Product {
  ResourceType get sourceResource;

  ConverterBaseProduct(Game game, ProductType productType) : super(game, productType);
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

class ConvertProduct extends ConverterBaseProduct {
  final ResourceType source;
  final ResourceType dest;

  ConvertProduct(Game game, this.source, this.dest) : super(game, ProductType.convert);

  @override
  ResourceType get sourceResource => source;

  @override
  GameAction produce(Game game, String player) {
    return ConvertAction(player, source, dest, this);
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

class DoubleResourceProduct extends ConverterBaseProduct {
  final ResourceType resourceType;

  DoubleResourceProduct(Game game, this.resourceType) : super(game, ProductType.doubleResource);

  @override
  ResourceType get sourceResource => resourceType;

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

/// SpendResourceProduct is used only when describing possible ways
/// to spend resources.  It's returned as a Product in PlayerData.getMaxResources()
class SpendResourceProduct extends ConverterBaseProduct {
  final ResourceType resourceType;

  SpendResourceProduct(Game game, this.resourceType) : super(game, ProductType.spend);

  @override
  ResourceType get sourceResource => resourceType;

  @override
  GameAction produce(Game game, String player) {
    throw InvalidOperationError('Spend product should not be produced');
  }
}
