import 'package:engine/engine.dart';

class EnhancementPart extends Part {
  final int resourceStorage;
  final int partStorage;
  final int scavenge;
  final int _vp;

  EnhancementPart(Game game, String id, int level, int cost, ResourceType resource, int vp, this.resourceStorage,
      this.partStorage, this.scavenge)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}
