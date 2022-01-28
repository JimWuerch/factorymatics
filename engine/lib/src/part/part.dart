import 'package:engine/engine.dart';
import 'package:engine/src/part/converter_part.dart';

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
  bool operator ==(Object other) => identical(this, other) || other is Part && runtimeType == other.runtimeType && id == other.id;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => id.hashCode;
}

// blue = club
// red = heart
// black = spade
// yellow = diamond
void createParts(Game game) {
  var parts = <Part>[];
  var partId = 1;

  // the starting level 0 part
  parts.add(SimplePart(game, Part.startingPartId, -1, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct(game)], ResourceType.none, 0));

  // level 1 parts
  //game.partDecks[0] = ListState<Part>(game, 'level0Parts')
  parts
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, ConvertTrigger(ResourceType.club), ConvertProduct(game, ResourceType.club, ResourceType.any), ResourceType.heart, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 0, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [MysteryMeatProduct(game)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)], [AcquireProduct(game)], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)], [MysteryMeatProduct(game)], ResourceType.diamond, 1));

  var testPartId = 100;
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
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.acquire, 2, [AcquireTrigger(ResourceType.club), AcquireTrigger(ResourceType.spade)], [MysteryMeatProduct(game)],
        ResourceType.heart, 2))
    ..add(SimplePart(game, (partId++).toString(), 1, PartType.construct, 3, [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)], [VpProduct(game, 1)],
        ResourceType.club, 3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, ConvertTrigger(ResourceType.diamond), DoubleResourceProduct(game, ResourceType.diamond), ResourceType.spade, 3));

  // remove these test parts
  parts
    ..add(ConverterPart(game, (testPartId++).toString(), 1, 3, ConvertTrigger(ResourceType.heart), DoubleResourceProduct(game, ResourceType.heart), ResourceType.club, 3))
    ..add(ConverterPart(game, (testPartId++).toString(), 1, 3, ConvertTrigger(ResourceType.club), DoubleResourceProduct(game, ResourceType.club), ResourceType.diamond, 3))
    ..add(ConverterPart(game, (testPartId++).toString(), 1, 3, ConvertTrigger(ResourceType.spade), DoubleResourceProduct(game, ResourceType.spade), ResourceType.heart, 3));

  //game.partDecks[2] = ListState<Part>(game, 'level2Parts')
  parts
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()], [MysteryMeatProduct(game), MysteryMeatProduct(game), MysteryMeatProduct(game)],
        ResourceType.club, 4))
    ..add(ConverterPart(game, (partId++).toString(), 2, 4, ConvertTrigger(ResourceType.any), ConvertProduct(game, ResourceType.any, ResourceType.any), ResourceType.diamond, 4))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(2)], [AcquireProduct(game), AcquireProduct(game)], ResourceType.heart, 6));

  // save all the parts into the parts dictionary
  for (var part in parts) {
    game.allParts[part.id] = part;
  }
  // for (var i = 0; i < 3; ++i) {
  //   for (var part in game.partDecks[i]) {
  //     game.allParts[part.id] = part;
  //   }
  // }

  // game.level3Parts.removeRange(16, game.level3Parts.length);
}
