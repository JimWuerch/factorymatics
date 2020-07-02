import 'package:engine/engine.dart';

class Player {
  final String name;
  final String id;
  final Map<PartType, List<Part>> parts;
  int _level3Parts = 0;
  int _vpChits = 0;
  int get vpChits => _vpChits;
  Map<ResourceType, int> resources;
  int resourceStorage;
  int partStorage;
  int scavenge;

  Player({this.name, this.id}) : parts = <PartType, List<Part>>{} {
    resources = <ResourceType, int>{};
    for (var resource in ResourceType.values) {
      if (resource != ResourceType.none && resource != ResourceType.any) {
        resources[resource] = 0;
      }
    }
    resourceStorage = 5;
    partStorage = 1;
    scavenge = 3;
  }

  void _doParts(void Function(Part) fn) {
    for (var partList in parts.values) {
      for (var part in partList) {
        fn(part);
      }
    }
  }

  void resetPartActivations() => _doParts((part) => part.activated = false);

  int resourceCount() {
    var ret = 0;
    _doParts((part) => ret++);
    return ret;
  }

  void buyPart(Part part, List<ResourceType> payment) {
    parts[part.partType].add(part);
    for (var resource in payment) {
      if (resources[resource] < 1) throw ArgumentError('can\'t afford part.');
      resources[resource] = resources[resource] - 1;
    }

    if (part.level == 3) _level3Parts++;
  }

  bool get gameEnded => parts.keys.length > 15 || _level3Parts > 3;

  int get score {
    var ret = 0;
    _doParts((part) => ret += part.vp);
    ret += vpChits;
    return ret;
  }

  void giveVpChit() => _vpChits++;

  bool get hasStorageSpace => resourceStorage > resourceCount();

  void storeResource(ResourceType resource) {
    resources[resource] = resources[resource] + 1;
  }
}
