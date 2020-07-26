import 'package:engine/engine.dart';

class EnhancementPart extends Part {
  final int resourceStorage;
  final int partStorage;
  final int search;
  final int _vp;

  EnhancementPart(Game game, String id, int level, int cost, ResourceType resource, int vp, this.resourceStorage,
      this.partStorage, this.search)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class Level2ConstructDiscountPart extends Part {
  final int level2ConstructDiscount;
  final int _vp;

  Level2ConstructDiscountPart(
      Game game, String id, int level, int cost, ResourceType resource, int vp, this.level2ConstructDiscount)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class ConstructFromSearchDiscountPart extends Part {
  final int constructFromSearchDiscount;
  final int _vp;

  ConstructFromSearchDiscountPart(
      Game game, String id, int level, int cost, ResourceType resource, int vp, this.constructFromSearchDiscount)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class ConstructFromStoreDiscountPart extends Part {
  final int constructFromStoreDiscount;
  final int _vp;

  ConstructFromStoreDiscountPart(
      Game game, String id, int level, int cost, ResourceType resource, int vp, this.constructFromStoreDiscount)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class DisallowStorePart extends Part {
  final int _vp;

  DisallowStorePart(Game game, String id, int level, int cost, ResourceType resource, int vp)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class DisallowSearchPart extends Part {
  final int _vp;

  DisallowSearchPart(Game game, String id, int level, int cost, ResourceType resource, int vp)
      : _vp = vp,
        super(game, id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}
