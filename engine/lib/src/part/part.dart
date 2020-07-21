import 'package:engine/engine.dart';
import 'package:engine/src/part/converter_part.dart';

import 'product.dart';
import 'trigger.dart';

export 'enhancement_part.dart';
export 'product.dart';
export 'simple_part.dart';
export 'trigger.dart';

enum PartType { enhancement, converter, storage, acquire, construct }

abstract class Part extends GameObject {
  final int level;
  final PartType partType;
  final int cost;
  final List<Trigger> triggers;
  final List<Product> products;
  final ResourceType resource;
  int get vp;
  GameStateVar<bool> activated;
  GameStateVar<bool> ready;

  Part(Game game, String id, this.level, this.partType, this.cost, this.triggers, this.products, this.resource)
      : activated = GameStateVar(game, 'part:$id:activated', true),
        ready = GameStateVar(game, 'part:$id:ready', false),
        super(id);

  // List<GameAction> getProducts(Game game, String playerId) {
  //   var ret = <GameAction>[];
  //   for (var product in products) {
  //     ret.add(product.produce(game, playerId));
  //   }
  //   return ret;
  // }
}

// blue = club
// red = heart
// black = spade
// yellow = diamond
void createParts(Game game) {
  var parts = <Part>[];
  var partId = 1;

  // level 1 parts
  //game.partDecks[0] = ListState<Part>(game, 'level0Parts')
  parts
    ..add(ConverterPart(game, (partId++).toString(), 0, 1, [ConvertTrigger(ResourceType.club)],
        [ConvertProduct(ResourceType.club, ResourceType.any)], ResourceType.heart, 1))
    ..add(EnhancementPart(game, (partId++).toString(), 0, 1, ResourceType.heart, 1, 1, 0, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.storage, 1, [StoreTrigger()], [MysteryMeatProduct()],
        ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()], ResourceType.heart, 1))
    ..add(SimplePart(game, (partId++).toString(), 0, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()], ResourceType.diamond, 1));

  //game.partDecks[1] = ListState<Part>(game, 'level1Parts')
  parts
    ..add(EnhancementPart(game, (partId++).toString(), 1, 3, ResourceType.club, 3, 2, 1, 2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.club), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()],
        ResourceType.heart,
        2))
    ..add(SimplePart(
        game,
        (partId++).toString(),
        1,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [VpProduct(1)],
        ResourceType.club,
        3))
    ..add(ConverterPart(game, (partId++).toString(), 1, 3, [ConvertTrigger(ResourceType.diamond)],
        [DoubleResourceProduct(ResourceType.diamond)], ResourceType.spade, 3));

  //game.partDecks[2] = ListState<Part>(game, 'level2Parts')
  parts
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(), MysteryMeatProduct(), MysteryMeatProduct()], ResourceType.club, 4))
    ..add(ConverterPart(game, (partId++).toString(), 2, 4, [ConvertTrigger(ResourceType.any)],
        [ConvertProduct(ResourceType.any, ResourceType.any)], ResourceType.diamond, 4))
    ..add(SimplePart(game, (partId++).toString(), 2, PartType.construct, 6, [ConstructLevelTrigger(2)],
        [AcquireProduct(), AcquireProduct()], ResourceType.heart, 6));

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
