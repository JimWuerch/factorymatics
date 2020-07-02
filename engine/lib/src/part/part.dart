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
  bool activated = false;

  Part(String id, this.level, this.partType, this.cost, this.triggers, this.products, this.resource) : super(id);
}

// blue = club
// red = heart
// black = spade
// yellow = diamond
void createParts(Game game) {
  game.level1Parts = [
    ConverterPart(game.nextObjectId(), 1, 1, [ConvertTrigger(ResourceType.club)], [ConvertProduct(ResourceType.club)],
        ResourceType.heart, 1),
    EnhancementPart(game.nextObjectId(), 1, 1, ResourceType.heart, 1, 1, 0, 1),
    SimplePart(
        game.nextObjectId(), 1, PartType.storage, 1, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.heart, 1),
    SimplePart(game.nextObjectId(), 1, PartType.construct, 1, [ConstructTrigger(ResourceType.spade)],
        [AcquireProduct()], ResourceType.heart, 1),
  ];
}
