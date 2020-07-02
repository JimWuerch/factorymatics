import 'package:engine/engine.dart';

class Player {
  final String name;
  final String id;
  final MapState<PartType, ListState<Part>> parts;
  int _level3Parts = 0;
  final GameStateVar<int> _vpChits;
  int get vpChits => _vpChits.value;
  Map<ResourceType, GameStateVar<int>> resources;
  int resourceStorage;
  int partStorage;
  int scavenge;
  Game game;
  final ListState<Part> savedParts;

  Player({this.game, this.name, this.id})
      : parts = MapState<PartType, ListState<Part>>(game, '$name:parts'),
        savedParts = ListState<Part>(game, '$name:savedParts'),
        _vpChits = GameStateVar(game, '$name:vpChits', 0) {
    resources = <ResourceType, GameStateVar<int>>{};
    for (var resource in ResourceType.values) {
      if (resource != ResourceType.none && resource != ResourceType.any) {
        resources[resource] = GameStateVar(game, '$name:${resource.toString()}', 0);
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

  void resetPartActivations() => _doParts((part) => part.activated.value = false);

  int resourceCount() {
    var ret = 0;
    _doParts((part) => ret++);
    return ret;
  }

  void buyPart(Part part, List<ResourceType> payment) {
    parts[part.partType].add(part);
    for (var resource in payment) {
      if (resources[resource].value < 1) throw ArgumentError('can\'t afford part.');
      resources[resource].value = resources[resource].value - 1;
    }

    if (part.level == 3) _level3Parts++;
  }

  void savePart(Part part) {
    if (savedParts.length >= partStorage) throw ArgumentError('can\'t save part, no space');
    savedParts.add(part);
  }

  void unsavePart(Part part) {
    if (!savedParts.contains(part)) throw ArgumentError('can\'t unsave part.  Part not in storage.');
    savedParts.remove(part);
  }

  bool get gameEnded => parts.length > 15 || _level3Parts > 3;

  int get score {
    var ret = 0;
    _doParts((part) => ret += part.vp);
    ret += vpChits;
    return ret;
  }

  void giveVpChit() => _vpChits.value = _vpChits.value + 1;

  bool get hasStorageSpace => resourceStorage > resourceCount();

  void storeResource(ResourceType resource) {
    resources[resource].value = resources[resource].value + 1;
  }
}
