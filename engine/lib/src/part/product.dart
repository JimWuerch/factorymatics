import 'package:engine/engine.dart';

enum ProductType { mysteryMeat, aquire, convert, vp, doubleResource, search, store, freeConstructL1, spend }

abstract class Product {
  final ProductType productType;
  Part part; // set in the part constructor
  int prodIndex; // also set in the part constructor
  //final GameStateVar<bool> activated;

  Product(this.productType); // : activated = GameStateVar(game, 'product:activated', false);

  GameAction produce(String player);
}

abstract class ConverterBaseProduct extends Product {
  ResourceType get sourceResource;

  ConverterBaseProduct(ProductType productType) : super(productType);
}

class MysteryMeatProduct extends Product {
  MysteryMeatProduct() : super(ProductType.mysteryMeat);

  @override
  GameAction produce(String player) {
    return MysteryMeatAction(player, this);
  }
}

class AcquireProduct extends Product {
  AcquireProduct() : super(ProductType.aquire);

  @override
  GameAction produce(String player) {
    return RequestAcquireAction(player, this);
  }
}

class ConvertProduct extends ConverterBaseProduct {
  final ResourceType source;
  final ResourceType dest;

  ConvertProduct(this.source, this.dest) : super(ProductType.convert);

  @override
  ResourceType get sourceResource => source;

  @override
  GameAction produce(String player) {
    return ConvertAction(player, source, dest, this);
  }

  @override
  String toString() {
    return 'Convert ${source.name} to ${dest.name}';
  }
}

class VpProduct extends Product {
  final int vp;

  VpProduct(this.vp) : super(ProductType.vp);

  @override
  GameAction produce(String player) {
    return VpAction(player, vp, this);
  }
}

class DoubleResourceProduct extends ConverterBaseProduct {
  final ResourceType resourceType;

  DoubleResourceProduct(this.resourceType) : super(ProductType.doubleResource);

  @override
  ResourceType get sourceResource => resourceType;

  @override
  GameAction produce(String player) {
    return DoubleConvertAction(player, resourceType, this);
  }

  @override
  String toString() {
    return 'Double ${resourceType.name}';
  }
}

class SearchProduct extends Product {
  SearchProduct() : super(ProductType.search);

  @override
  GameAction produce(String player) {
    return RequestSearchAction(player, this);
  }
}

class StoreProduct extends Product {
  StoreProduct() : super(ProductType.store);

  @override
  GameAction produce(String player) {
    return RequestStoreAction(player, this);
  }
}

class FreeConstructL1Product extends Product {
  final int level;

  FreeConstructL1Product(this.level) : super(ProductType.freeConstructL1);

  @override
  GameAction produce(String player) {
    return RequestConstructL1Action(player, this);
  }
}

/// SpendResourceProduct is used only when describing possible ways
/// to spend resources.  It's returned as a Product in PlayerData.getMaxResources()
class SpendResourceProduct extends ConverterBaseProduct {
  final ResourceType resourceType;

  SpendResourceProduct(this.resourceType) : super(ProductType.spend);

  @override
  ResourceType get sourceResource => resourceType;

  @override
  GameAction produce(String player) {
    throw InvalidOperationError('Spend product should not be produced');
  }

  @override
  String toString() {
    return 'Spend ${resourceType.name}';
  }
}
