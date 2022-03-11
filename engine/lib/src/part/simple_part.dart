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

  @override
  String toString() {
    var sb = StringBuffer();
    sb.write(triggers[0]);
    for (var i = 1; i < triggers.length; ++i) {
      sb.write(' or ${triggers[i]}');
    }
    if (products.isEmpty) return sb.toString();
    sb.write(' -> ${products[0].toString()}');
    for (var i = 1; i < products.length; i++) {
      sb.write(' and ${products[i].toString()}');
    }
    return sb.toString();
  }
}
