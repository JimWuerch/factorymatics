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

  Part(Game game, String id, this.level, this.partType, this.cost, this.triggers, this.products, this.resource)
      : activated = GameStateVar(game, 'part:$id:activated', false),
        super(id);
}

// blue = club
// red = heart
// black = spade
// yellow = diamond
void createParts(Game game) {
  game.level1Parts = [
    ConverterPart(game, game.nextObjectId(), 1, 1, [ConvertTrigger(ResourceType.club)],
        [ConvertProduct(ResourceType.club)], ResourceType.heart, 1),
    EnhancementPart(game, game.nextObjectId(), 1, 1, ResourceType.heart, 1, 1, 0, 1),
    SimplePart(game, game.nextObjectId(), 1, PartType.storage, 1, [StoreTrigger()], [MysteryMeatProduct()],
        ResourceType.heart, 1),
    SimplePart(game, game.nextObjectId(), 1, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()], ResourceType.heart, 1),
    SimplePart(game, game.nextObjectId(), 1, PartType.acquire, 1, [AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()], ResourceType.diamond, 1),
  ];

  game.level1Parts.shuffle();

  game.level2Parts = [
    EnhancementPart(game, game.nextObjectId(), 2, 3, ResourceType.club, 3, 2, 1, 2),
    SimplePart(
        game,
        game.nextObjectId(),
        2,
        PartType.acquire,
        2,
        [AcquireTrigger(ResourceType.club), AcquireTrigger(ResourceType.spade)],
        [MysteryMeatProduct()],
        ResourceType.heart,
        2),
    SimplePart(
        game,
        game.nextObjectId(),
        2,
        PartType.construct,
        3,
        [ConstructTrigger(ResourceType.spade), ConstructTrigger(ResourceType.heart)],
        [VpProduct(1)],
        ResourceType.club,
        3),
    ConverterPart(game, game.nextObjectId(), 2, 3, [ConvertTrigger(ResourceType.diamond)],
        [DoubleResourceProduct(ResourceType.diamond)], ResourceType.spade, 3),
  ];

  game.level2Parts.shuffle();

  game.level3Parts = [
    SimplePart(game, game.nextObjectId(), 3, PartType.storage, 4, [StoreTrigger()],
        [MysteryMeatProduct(), MysteryMeatProduct(), MysteryMeatProduct()], ResourceType.club, 4),
    ConverterPart(game, game.nextObjectId(), 3, 4, [ConvertTrigger(ResourceType.any)],
        [ConvertProduct(ResourceType.any)], ResourceType.diamond, 4),
    SimplePart(game, game.nextObjectId(), 3, PartType.construct, 6, [ConstructLevelTrigger(2)],
        [AcquireProduct(), AcquireProduct()], ResourceType.heart, 6),
  ];
  game.level3Parts.shuffle();
  // game.level3Parts.removeRange(16, game.level3Parts.length);
}
