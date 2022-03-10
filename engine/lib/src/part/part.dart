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

  Part(String id, this.level, this.partType, this.cost, this.triggers, this.products, this.resource) : super(id) {
    // take ownership of the products
    for (var index = 0; index < products.length; ++index) {
      products[index].part = this;
      products[index].prodIndex = index;
    }
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
List<Part> createParts() {
  var parts = <Part>[];
  var partId = 1;

  // the starting level 0 part
  parts.add(SimplePart(
      Part.startingPartId, -1, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.none, 0));

  // level 1 parts
  parts
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.club),
        ConvertProduct(ResourceType.club, ResourceType.any), ResourceType.heart, 1))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 0, 1))
    ..add(SimplePart(
        (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct()], ResourceType.heart, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()], ResourceType.heart, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()], ResourceType.diamond, 1))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.spade, 1, 1, 1, 0))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.diamond, 1, 1, 1, 0))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.spade, 1, 1, 0, 1))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.diamond, 1, 1, 0, 1))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 1, 0))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.club, 1, 1, 1, 0))
    ..add(EnhancementPart((partId++).toString(), 0, 1, ResourceType.club, 1, 1, 0, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.diamond)],
        [VpProduct(1)], ResourceType.heart, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [VpProduct(1)], ResourceType.club, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.club)],
        [VpProduct(1)], ResourceType.diamond, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.diamond)],
        [AcquireProduct()], ResourceType.club, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.heart)],
        [AcquireProduct()], ResourceType.diamond, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.club)],
        [AcquireProduct()], ResourceType.spade, 1))
    // partId == 19 here
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.spade),
        ConvertProduct(ResourceType.spade, ResourceType.any), ResourceType.heart, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.club),
        ConvertProduct(ResourceType.club, ResourceType.any), ResourceType.diamond, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.spade),
        ConvertProduct(ResourceType.spade, ResourceType.any), ResourceType.diamond, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.heart),
        ConvertProduct(ResourceType.heart, ResourceType.any), ResourceType.spade, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.diamond),
        ConvertProduct(ResourceType.diamond, ResourceType.any), ResourceType.club, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.diamond),
        ConvertProduct(ResourceType.diamond, ResourceType.any), ResourceType.spade, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct()], ResourceType.club, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.diamond)],
        [MysteryMeatProduct()], ResourceType.heart, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct()], ResourceType.heart, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.diamond)],
        [MysteryMeatProduct()], ResourceType.spade, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct()], ResourceType.diamond, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct()], ResourceType.spade, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()], ResourceType.club, 1))
    ..add(ConverterPart((partId++).toString(), 0, 1, ConvertTrigger(ResourceType.heart),
        ConvertProduct(ResourceType.heart, ResourceType.any), ResourceType.club, 1))
    ..add(SimplePart((partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.heart)],
        [VpProduct(1)], ResourceType.spade, 1))
    ..add(SimplePart(
        (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct()], ResourceType.club, 1))
    ..add(SimplePart(
        (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct()], ResourceType.diamond, 1))
    ..add(SimplePart(
        (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [AcquireProduct()], ResourceType.spade, 1));

  parts
    ..add(EnhancementPart((partId++).toString(), 1, 3, ResourceType.club, 3, 2, 1, 2))
    ..add(EnhancementPart((partId++).toString(), 1, 3, ResourceType.spade, 3, 2, 1, 2))
    ..add(EnhancementPart((partId++).toString(), 1, 3, ResourceType.heart, 3, 2, 1, 2))
    ..add(EnhancementPart((partId++).toString(), 1, 3, ResourceType.diamond, 3, 2, 1, 2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [VpProduct(1)],
        ResourceType.spade,
        3))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [VpProduct(1)],
        ResourceType.heart,
        3))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [VpProduct(1)],
        ResourceType.diamond,
        3))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [VpProduct(1)],
        ResourceType.club,
        3))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [AcquireProduct()],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct()],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()],
        ResourceType.diamond,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [AcquireProduct()],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct()],
        ResourceType.diamond,
        2))
    // partId == 50
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()],
        ResourceType.club,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.construct,
        2,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [AcquireProduct()],
        ResourceType.club,
        2))
    ..add(SimplePart((partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(), AcquireProduct()], ResourceType.club, 3))
    ..add(SimplePart((partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(), AcquireProduct()], ResourceType.spade, 3))
    ..add(SimplePart((partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(), AcquireProduct()], ResourceType.heart, 3))
    ..add(SimplePart((partId++).toString(), 1, PartType.construct, 3, [ConstructFromStoreTrigger()],
        [AcquireProduct(), AcquireProduct()], ResourceType.diamond, 3))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.diamond), AcquireTrigger(ResourceType.heart)],
        [MysteryMeatProduct()],
        ResourceType.spade,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.club), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.diamond), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()],
        ResourceType.club,
        2))
    ..add(SimplePart(
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.heart), AcquireTrigger(ResourceType.club)],
        [MysteryMeatProduct()],
        ResourceType.diamond,
        2))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.spade),
        DoubleResourceProduct(ResourceType.spade), ResourceType.diamond, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.club),
        DoubleResourceProduct(ResourceType.club), ResourceType.diamond, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.diamond),
        DoubleResourceProduct(ResourceType.diamond), ResourceType.spade, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.diamond),
        DoubleResourceProduct(ResourceType.diamond), ResourceType.club, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.club),
        DoubleResourceProduct(ResourceType.club), ResourceType.heart, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.heart),
        DoubleResourceProduct(ResourceType.heart), ResourceType.club, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.spade),
        DoubleResourceProduct(ResourceType.spade), ResourceType.heart, 3))
    ..add(ConverterPart((partId++).toString(), 1, 3, ConvertTrigger(ResourceType.heart),
        DoubleResourceProduct(ResourceType.heart), ResourceType.spade, 3))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        1,
        2,
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.diamond),
            ConvertProduct(ResourceType.diamond, ResourceType.any), ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.diamond),
            ConvertProduct(ResourceType.diamond, ResourceType.any), ResourceType.any, 1),
        ResourceType.heart,
        2))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        1,
        2,
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.heart),
            ConvertProduct(ResourceType.heart, ResourceType.any), ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.heart),
            ConvertProduct(ResourceType.heart, ResourceType.any), ResourceType.any, 1),
        ResourceType.diamond,
        2))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        1,
        2,
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.spade),
            ConvertProduct(ResourceType.spade, ResourceType.any), ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.spade),
            ConvertProduct(ResourceType.spade, ResourceType.any), ResourceType.any, 1),
        ResourceType.club,
        2))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        1,
        2,
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.club), ConvertProduct(ResourceType.club, ResourceType.any),
            ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.club), ConvertProduct(ResourceType.club, ResourceType.any),
            ResourceType.any, 1),
        ResourceType.spade,
        2));

  parts
    ..add(SimplePart(
        (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()], [VpProduct(1)], ResourceType.spade, 4))
    ..add(SimplePart(
        (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()], [VpProduct(1)], ResourceType.heart, 4))
    ..add(SimplePart((partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(), MysteryMeatProduct(), MysteryMeatProduct()], ResourceType.diamond, 4))
    ..add(SimplePart((partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(), MysteryMeatProduct(), MysteryMeatProduct()], ResourceType.club, 4))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [StoreProduct()],
        ResourceType.diamond,
        5))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.diamond)],
        [StoreProduct()],
        ResourceType.spade,
        5))
    // partId == 79
    ..add(Level2ConstructDiscountPart((partId++).toString(), 2, 5, ResourceType.diamond, 5, 1))
    ..add(Level2ConstructDiscountPart((partId++).toString(), 2, 5, ResourceType.club, 5, 1))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        7,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [SearchProduct()],
        ResourceType.heart,
        7))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        7,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [SearchProduct()],
        ResourceType.club,
        7))
    ..add(SimplePart((partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(1)],
        [AcquireProduct(), AcquireProduct()], ResourceType.heart, 6))
    ..add(SimplePart((partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(1)],
        [AcquireProduct(), AcquireProduct()], ResourceType.spade, 6))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.heart), ConstructTrigger(ResourceType.club)],
        [VpProduct(2)],
        ResourceType.spade,
        5))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        5,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.spade)],
        [VpProduct(2)],
        ResourceType.heart,
        5))
    ..add(SimplePart((partId++).toString(), 2, PartType.construct, 5, [ConstructFromStoreTrigger()], [VpProduct(2)],
        ResourceType.heart, 5))
    ..add(SimplePart((partId++).toString(), 2, PartType.construct, 5, [ConstructFromStoreTrigger()], [VpProduct(2)],
        ResourceType.diamond, 5))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        6,
        [ConstructTrigger(ResourceType.club), ConstructTrigger(ResourceType.spade)],
        [FreeConstructL1Product(0)],
        ResourceType.diamond,
        6))
    ..add(SimplePart(
        (partId++).toString(),
        2,
        PartType.construct,
        6,
        [ConstructTrigger(ResourceType.diamond), ConstructTrigger(ResourceType.heart)],
        [FreeConstructL1Product(0)],
        ResourceType.club,
        6))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        2,
        5,
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.spade), DoubleResourceProduct(ResourceType.spade),
            ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.heart), DoubleResourceProduct(ResourceType.heart),
            ResourceType.any, 1),
        ResourceType.club,
        5))
    ..add(MultipleConverterPart(
        (partId++).toString(),
        2,
        5,
        ConverterPart(
            '', 0, 1, ConvertTrigger(ResourceType.club), DoubleResourceProduct(ResourceType.club), ResourceType.any, 1),
        ConverterPart('', 0, 1, ConvertTrigger(ResourceType.diamond), DoubleResourceProduct(ResourceType.diamond),
            ResourceType.any, 1),
        ResourceType.spade,
        5))
    ..add(ConverterPart((partId++).toString(), 2, 4, ConvertTrigger(ResourceType.any),
        ConvertProduct(ResourceType.any, ResourceType.any), ResourceType.diamond, 4))
    ..add(ConverterPart((partId++).toString(), 2, 4, ConvertTrigger(ResourceType.any),
        ConvertProduct(ResourceType.any, ResourceType.any), ResourceType.heart, 4))
    ..add(EnhancementPart((partId++).toString(), 2, 4, ResourceType.club, 4, 4, 0, 0))
    ..add(EnhancementPart((partId++).toString(), 2, 4, ResourceType.spade, 4, 4, 0, 0))
    ..add(ConstructFromStoreDiscountPart((partId++).toString(), 2, 5, ResourceType.club, 5, 1))
    ..add(ConstructFromStoreDiscountPart((partId++).toString(), 2, 5, ResourceType.heart, 5, 1))
    // partId == 99
    ..add(VpChitDoublerPart((partId++).toString(), 2, 7))
    ..add(VpChitDoublerPart((partId++).toString(), 2, 7))
    ..add(VpIsResourcesPart((partId++).toString(), 2, 7))
    ..add(VpIsResourcesPart((partId++).toString(), 2, 7))
    ..add(ConstructFromSearchDiscountPart((partId++).toString(), 2, 6, ResourceType.spade, 6, 1))
    ..add(ConstructFromSearchDiscountPart((partId++).toString(), 2, 6, ResourceType.diamond, 6, 1))
    ..add(DisallowStorePart((partId++).toString(), 2, 4, ResourceType.club, 7))
    ..add(DisallowStorePart((partId++).toString(), 2, 4, ResourceType.heart, 7))
    ..add(DisallowSearchPart((partId++).toString(), 2, 4, ResourceType.diamond, 8))
    ..add(DisallowSearchPart((partId++).toString(), 2, 4, ResourceType.spade, 8));
  return parts;
}
