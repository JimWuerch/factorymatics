import 'package:engine/engine.dart';

class ConverterPart extends Part {
  final int _vp;

  ConverterPart(
      Game game, String id, int level, int cost, Trigger trigger, Product product, ResourceType resourceType, int vp)
      : _vp = vp,
        super(game, id, level, PartType.converter, cost, <Trigger>[trigger], <Product>[product], resourceType);

  @override
  int get vp => _vp;

  bool canConvert(ResourceType resource) {
    for (var t in triggers) {
      var trigger = t as ConvertTrigger;
      if (trigger.resourceType == resource) {
        return true;
      }
    }
    return false;
  }
}

class MultipleConverterPart extends Part {
  static const int numberOfParts = 2;
  final int _vp;

  MultipleConverterPart(Game game, String id, int level, int cost, Trigger trigger1, Product product1, Trigger trigger2,
      Product product2, ResourceType resourceType, int vp)
      : _vp = vp,
        super(game, id, level, PartType.converter, cost, <Trigger>[trigger1, trigger2], <Product>[product1, product2],
            resourceType);

  @override
  int get vp => _vp;

  bool canConvert(int converterNumber, ResourceType resource) {
    var trigger = triggers[converterNumber] as ConvertTrigger;
    if (trigger.resourceType == resource) {
      return true;
    }
    return false;
  }
}
