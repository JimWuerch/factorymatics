import 'package:engine/engine.dart';

class SimplePart extends Part {
  final int _vp;

  SimplePart(String id, int level, PartType partType, int cost, List<Trigger> triggers, List<Product> products,
      ResourceType resourceType, int vp)
      : _vp = vp,
        super(id, level, partType, cost, triggers, products, resourceType);

  @override
  int get vp => _vp;

  @override
  String get desc => 'Level $level Part $id';
}
