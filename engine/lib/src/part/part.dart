import 'package:engine/engine.dart';

export 'converter_part.dart';
export 'enhancement_part.dart';
export 'product.dart';
export 'simple_part.dart';
export 'trigger.dart';

enum PartType { enhancement, converter, storage, acquire, construct }

abstract class Part extends GameObject {
  static const String startingPartId = "0";

  final int level;
  final PartType partType;
  final int cost;
  final List<Trigger> triggers;
  final List<Product> products;
  final ResourceType resource;
  int get vp;
  final GameStateVar<bool> ready;

  Part(Game game, String id, this.level, this.partType, this.cost, this.triggers, this.products, this.resource)
      : ready = GameStateVar(game, 'part:$id:ready', false),
        super(id) {
    // take ownership of the products
    for (var index = 0; index < products.length; ++index) {
      products[index].part = this;
      products[index].prodIndex = index;
    }
  }

  void resetActivations() {
    for (var product in products) {
      product.activated.reinitialize(false);
    }
  }

  // for serialization, we just need to know which parts
  // have been activated
  String getProductsState() {
    var ret = "P";
    for (var product in products) {
      if (product.activated.value) {
        ret += "1";
      } else {
        ret += "0";
      }
    }
    return ret;
  }

  // The string is the letter P followed by a 1 or 0 for each product
  void setProductsState(String states) {
    if (states[0] != 'P') throw ArgumentError("states must start with P");
    for (var index = 0; index < products.length; ++index) {
      products[index].activated.reinitialize(states[index + 1] == '1');
    }
  }

  String getPartSerializeString() {
    return '${ready.value ? '1' : '0'}:${getProductsState()}';
  }

  void setPartFromSerializeString(String state) {
    var index = state.indexOf(':');
    ready.reinitialize(state.substring(0, index) == '1');
    setProductsState(state.substring(index + 1));
  }

  Product productFromIndex(int index) {
    return products[index];
  }

  int getProductIndex(Product product) {
    var index = products.indexOf(product);
    return index != -1 ? index : null;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) || other is Part && runtimeType == other.runtimeType && id == other.id;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => id.hashCode;
}

// blue = club
// red = heart
// black = spade
// yellow = diamond
List<Part> createParts(Game game) {
  var parts = <Part>[];
  var partId = 1;

  // the starting level 0 part
  parts.add(SimplePart(game, Part.startingPartId, -1, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct(game)],
      ResourceType.none, 0));

  // level 1 parts
  //game.partDecks[0] = ListState<Part>(game, 'level0Parts')
  parts
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.club),
        ConvertProduct(game, ResourceType.club, ResourceType.any), ResourceType.heart, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 0, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct(game)],
        ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [AcquireProduct(game)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct(game)], ResourceType.diamond, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.spade, 1, 1, 1, 0))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.diamond, 1, 1, 1, 0))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.spade, 1, 1, 0, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.diamond, 1, 1, 0, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 1, 0))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.club, 1, 1, 1, 0))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.club, 1, 1, 0, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.diamond)],
        [VpProduct(game, 1)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [VpProduct(game, 1)], ResourceType.club, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.club)],
        [VpProduct(game, 1)], ResourceType.diamond, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.diamond)],
        [AcquireProduct(game)], ResourceType.club, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.heart)],
        [AcquireProduct(game)], ResourceType.diamond, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.club)],
        [AcquireProduct(game)], ResourceType.spade, 1))
    // partId == 19 here
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.spade),
        ConvertProduct(game, ResourceType.spade, ResourceType.any), ResourceType.heart, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.club),
        ConvertProduct(game, ResourceType.club, ResourceType.any), ResourceType.diamond, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.spade),
        ConvertProduct(game, ResourceType.spade, ResourceType.any), ResourceType.diamond, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.heart),
        ConvertProduct(game, ResourceType.heart, ResourceType.any), ResourceType.spade, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.diamond),
        ConvertProduct(game, ResourceType.diamond, ResourceType.any), ResourceType.club, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.diamond),
        ConvertProduct(game, ResourceType.diamond, ResourceType.any), ResourceType.spade, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct(game)], ResourceType.club, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.diamond)],
        [MysteryMeatProduct(game)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct(game)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.diamond)],
        [MysteryMeatProduct(game)], ResourceType.spade, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct(game)], ResourceType.diamond, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct(game)], ResourceType.spade, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct(game)], ResourceType.club, 1))
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.heart),
        ConvertProduct(game, ResourceType.heart, ResourceType.any), ResourceType.club, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.heart)],
        [VpProduct(game, 1)], ResourceType.spade, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct(game)],
        ResourceType.club, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct(game)],
        ResourceType.diamond, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct(game)],
        ResourceType.spade, 1));

  //var testPartId = 100;
  // remove these test parts when we add real ones
  // parts
  //   ..add(ConverterPart(game, (testPartId++).toString(), 0, 1, ConvertTrigger(ResourceType.heart), ConvertProduct(game, ResourceType.heart, ResourceType.any), ResourceType.club, 1))
  //   ..add(ConverterPart(game, (testPartId++).toString(), 0, 1, ConvertTrigger(ResourceType.diamond), ConvertProduct(game, ResourceType.diamond, ResourceType.any), ResourceType.spade, 1))
  //   ..add(ConverterPart(game, (testPartId++).toString(), 0, 1, ConvertTrigger(ResourceType.spade), ConvertProduct(game, ResourceType.spade, ResourceType.any), ResourceType.diamond, 1))
  //   ..add(SimplePart(game, (testPartId++).toString(), 0, PartType.acquire, 1, [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.heart)], [VpProduct(game, 1)],
  //       ResourceType.heart, 2));

  //game.partDecks[1] = ListState<Part>(game, 'level1Parts')
  parts
    ..add(EnhancementPart(game, (partId++).toString(), 1, 3, ResourceType.club, 3, 2, 1, 2))
    ..add(EnhancementPart(game, (partId++).toString(), 1, 3, ResourceType.spade, 3, 2, 1, 2))
    ..add(EnhancementPart(game, (partId++).toString(), 1, 3, ResourceType.heart, 3, 2, 1, 2))
    ..add(EnhancementPart(game, (partId++).toString(), 1, 3, ResourceType.diamond, 3, 2, 1, 2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [VpProduct(game, 1)],
        ResourceType.spade,
        3))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [VpProduct(game, 1)],
        ResourceType.heart,
        3))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [VpProduct(game, 1)],
        ResourceType.diamond,
        3))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [VpProduct(game, 1)],
        ResourceType.club,
        3))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [AcquireProduct(game)],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct(game)],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct(game)],
        ResourceType.diamond,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [AcquireProduct(game)],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct(game)],
        ResourceType.diamond,
        2))
    // partId == 50
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct(game)],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct(game)],
        ResourceType.club,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct(game)],
        ResourceType.club,
        2))
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.club, 3))
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.spade, 3))
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.heart, 3))
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.diamond, 3))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.diamond), AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct(game)],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.club), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct(game)],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.diamond), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct(game)],
        ResourceType.club,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.heart), AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct(game)],
        ResourceType.diamond,
        2))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.spade),
        DoubleResourceProduct(game, ResourceType.spade), ResourceType.diamond, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.club),
        DoubleResourceProduct(game, ResourceType.club), ResourceType.diamond, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.diamond),
        DoubleResourceProduct(game, ResourceType.diamond), ResourceType.spade, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.diamond),
        DoubleResourceProduct(game, ResourceType.diamond), ResourceType.club, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.club),
        DoubleResourceProduct(game, ResourceType.club), ResourceType.heart, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.heart),
        DoubleResourceProduct(game, ResourceType.heart), ResourceType.club, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.spade),
        DoubleResourceProduct(game, ResourceType.spade), ResourceType.heart, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.heart),
        DoubleResourceProduct(game, ResourceType.heart), ResourceType.spade, 3))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        1,
        2,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.diamond),
            ConvertProduct(game, ResourceType.diamond, ResourceType.any), ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.diamond),
            ConvertProduct(game, ResourceType.diamond, ResourceType.any), ResourceType.any, 1),
        ResourceType.heart,
        2))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        1,
        2,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.heart),
            ConvertProduct(game, ResourceType.heart, ResourceType.any), ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.heart),
            ConvertProduct(game, ResourceType.heart, ResourceType.any), ResourceType.any, 1),
        ResourceType.diamond,
        2))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        1,
        2,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.spade),
            ConvertProduct(game, ResourceType.spade, ResourceType.any), ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.spade),
            ConvertProduct(game, ResourceType.spade, ResourceType.any), ResourceType.any, 1),
        ResourceType.club,
        2))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        1,
        2,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.club),
            ConvertProduct(game, ResourceType.club, ResourceType.any), ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.club),
            ConvertProduct(game, ResourceType.club, ResourceType.any), ResourceType.any, 1),
        ResourceType.spade,
        2));

  parts
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()], [VpProduct(game, 1)],
        ResourceType.spade, 4))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()], [VpProduct(game, 1)],
        ResourceType.heart, 4))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(game), MysteryMeatProduct(game), MysteryMeatProduct(game)], ResourceType.diamond, 4))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(game), MysteryMeatProduct(game), MysteryMeatProduct(game)], ResourceType.club, 4))
    // TODO: fix StoreProduct
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [StoreProduct(game)],
        ResourceType.diamond,
        5))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [StoreProduct(game)],
        ResourceType.spade,
        5))
    // partId == 79
    // TODO: fix Level2ConstructDiscountPart
    ..add(Level2ConstructDiscountPart(game, (partId++).toString(), 2, 5, ResourceType.diamond, 5, 1))
    ..add(Level2ConstructDiscountPart(game, (partId++).toString(), 2, 5, ResourceType.club, 5, 1))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        7,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [SearchProduct(game)],
        ResourceType.heart,
        7))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        7,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [SearchProduct(game)],
        ResourceType.club,
        7))
    // TODO: fix ConstructLevelTrigger
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(1)],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.heart, 6))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(1)],
        [AcquireProduct(game), AcquireProduct(game)], ResourceType.spade, 6))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [VpProduct(game, 2)],
        ResourceType.spade,
        5))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [VpProduct(game, 2)],
        ResourceType.heart,
        5))
    // TODO: fix ConstructFromStoreTrigger
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 5, [ConstructFromStoreTrigger()],
        [VpProduct(game, 2)], ResourceType.heart, 5))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 5, [ConstructFromStoreTrigger()],
        [VpProduct(game, 2)], ResourceType.diamond, 5))
    // TODO: fix FreeConstructProduct
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        6,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [FreeConstructL1Product(game, 0)],
        ResourceType.diamond,
        6))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        2,
        PartType.construct,
        6,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [FreeConstructL1Product(game, 0)],
        ResourceType.club,
        6))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        2,
        5,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.spade),
            DoubleResourceProduct(game, ResourceType.spade), ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.heart),
            DoubleResourceProduct(game, ResourceType.heart), ResourceType.any, 1),
        ResourceType.club,
        5))
    ..add(MultipleConverterPart(
        game,
        (partId++).toString(),
        2,
        5,
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.club), DoubleResourceProduct(game, ResourceType.club),
            ResourceType.any, 1),
        ConverterPart(game, '', 0, 1, ConvertTrigger(ResourceType.diamond),
            DoubleResourceProduct(game, ResourceType.diamond), ResourceType.any, 1),
        ResourceType.spade,
        5))
    // TODO: fix Any to Any converter
    ..add(ConverterPart(game, (partId++).toString(), 2, 4, ConvertTrigger(ResourceType.any),
        ConvertProduct(game, ResourceType.any, ResourceType.any), ResourceType.diamond, 4))
    ..add(ConverterPart(game, (partId++).toString(), 2, 4, ConvertTrigger(ResourceType.any),
        ConvertProduct(game, ResourceType.any, ResourceType.any), ResourceType.heart, 4))
    ..add(EnhancementPart(game, (partId++).toString(), 2, 4, ResourceType.club, 4, 4, 0, 0))
    ..add(EnhancementPart(game, (partId++).toString(), 2, 4, ResourceType.spade, 4, 4, 0, 0))
    // TODO: fix ConstructFromStoreDiscountPart
    ..add(ConstructFromStoreDiscountPart(game, (partId++).toString(), 2, 5, ResourceType.club, 5, 1))
    ..add(ConstructFromStoreDiscountPart(game, (partId++).toString(), 2, 5, ResourceType.heart, 5, 1))
    // partId == 99
    // TODO: fix VpChitDoublerPart
    ..add(VpChitDoublerPart(game, (partId++).toString(), 2, 7))
    ..add(VpChitDoublerPart(game, (partId++).toString(), 2, 7))
    // TODO: fix VpIsResourcesPart
    ..add(VpIsResourcesPart(game, (partId++).toString(), 2, 7))
    ..add(VpIsResourcesPart(game, (partId++).toString(), 2, 7))
    // TODO: fix ConstructFromSearchDiscountPart
    ..add(ConstructFromSearchDiscountPart(game, (partId++).toString(), 2, 6, ResourceType.spade, 6, 1))
    ..add(ConstructFromSearchDiscountPart(game, (partId++).toString(), 2, 6, ResourceType.diamond, 6, 1))
    // TODO: fix DisallowStorePart
    ..add(DisallowStorePart(game, (partId++).toString(), 2, 4, ResourceType.club, 7))
    ..add(DisallowStorePart(game, (partId++).toString(), 2, 4, ResourceType.heart, 7))
    // TODO: fix DisallowSearchPart
    ..add(DisallowSearchPart(game, (partId++).toString(), 2, 4, ResourceType.diamond, 8))
    ..add(DisallowSearchPart(game, (partId++).toString(), 2, 4, ResourceType.spade, 8));

  // save all the parts into the parts dictionary
  // for (var part in parts) {
  //   game.allParts[part.id] = part;
  // }

  // for (var i = 0; i < 3; ++i) {
  //   for (var part in game.partDecks[i]) {
  //     game.allParts[part.id] = part;
  //   }
  // }

  // game.level3Parts.removeRange(16, game.level3Parts.length);

  return parts;
}
