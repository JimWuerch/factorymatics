import 'package:engine/engine.dart';

class ConverterPart extends Part {
  final int _vp;

  ConverterPart(String id, int level, int cost, Trigger trigger, Product product, ResourceType resourceType, int vp)
      : _vp = vp,
        super(id, level, PartType.converter, cost, <Trigger>[trigger], <Product>[product], resourceType);

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
  //static const int numberOfParts = 2;
  final int _vp;
  final List<ConverterPart> converters;

  MultipleConverterPart(String id, int level, int cost, ConverterPart converter1, ConverterPart converter2,
      ResourceType resourceType, int vp)
      : converters = <ConverterPart>[converter1, converter2],
        _vp = vp,
        super(id, level, PartType.converter, cost, <Trigger>[converter1.triggers[0], converter2.triggers[0]],
            <Product>[converter1.products[0], converter2.products[0]], resourceType);

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
