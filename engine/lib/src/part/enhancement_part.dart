import 'package:engine/engine.dart';

class EnhancementPart extends Part {
  final int resourceStorage;
  final int partStorage;
  final int search;
  final int _vp;

  EnhancementPart(String id, int level, int cost, ResourceType resource, int vp, this.resourceStorage, this.partStorage,
      this.search)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class Level2ConstructDiscountPart extends Part {
  final int level2ConstructDiscount;
  final int _vp;

  Level2ConstructDiscountPart(
      String id, int level, int cost, ResourceType resource, int vp, this.level2ConstructDiscount)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class ConstructFromSearchDiscountPart extends Part {
  final int constructFromSearchDiscount;
  final int _vp;

  ConstructFromSearchDiscountPart(
      String id, int level, int cost, ResourceType resource, int vp, this.constructFromSearchDiscount)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class ConstructFromStoreDiscountPart extends Part {
  final int constructFromStoreDiscount;
  final int _vp;

  ConstructFromStoreDiscountPart(
      String id, int level, int cost, ResourceType resource, int vp, this.constructFromStoreDiscount)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class DisallowStorePart extends Part {
  final int _vp;

  DisallowStorePart(String id, int level, int cost, ResourceType resource, int vp)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

class DisallowSearchPart extends Part {
  final int _vp;

  DisallowSearchPart(String id, int level, int cost, ResourceType resource, int vp)
      : _vp = vp,
        super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], resource);

  @override
  int get vp => _vp;
}

abstract class CalculatedVpPart extends Part {
  int _vp = 0;
  @override
  int get vp => _vp;

  CalculatedVpPart(String id, int level, int cost)
      : super(id, level, PartType.enhancement, cost, <Trigger>[], <Product>[], ResourceType.any);

  void updateVp(PlayerData player);
}

class VpChitDoublerPart extends CalculatedVpPart {
  VpChitDoublerPart(String id, int level, int cost) : super(id, level, cost);

  @override
  void updateVp(PlayerData player) {
    _vp = player.vpChits;
  }
}

class VpIsResourcesPart extends CalculatedVpPart {
  VpIsResourcesPart(String id, int level, int cost) : super(id, level, cost);

  @override
  void updateVp(PlayerData player) {
    _vp = player.resourceCount();
  }
}
