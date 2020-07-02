import 'package:engine/engine.dart';

class ConverterPart extends Part {
  final int _vp;

  ConverterPart(Game game, String id, int level, int cost, List<Trigger> triggers, List<Product> products,
      ResourceType resourceType, int vp)
      : _vp = vp,
        super(game, id, level, PartType.converter, cost, triggers, null, resourceType);

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
