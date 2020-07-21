import 'package:engine/engine.dart';
import 'package:engine/src/part/converter_part.dart';
import 'package:engine/src/player/player.dart';

class PlayerData {
  //final String name;
  final String id;
  final MapState<PartType, ListState<Part>> parts;
  int _level3Parts = 0;
  final GameStateVar<int> _vpChits;
  int get vpChits => _vpChits.value;
  Map<ResourceType, GameStateVar<int>> resources;
  int resourceStorage;
  int partStorage;
  int search;
  Game game;
  final ListState<Part> savedParts;

  PlayerData(this.game, String playerId)
      : parts = MapState<PartType, ListState<Part>>(game, '$playerId:parts'),
        savedParts = ListState<Part>(game, '$playerId:savedParts'),
        _vpChits = GameStateVar(game, '$playerId:vpChits', 0),
        // ignore: prefer_initializing_formals
        id = playerId {
    resources = <ResourceType, GameStateVar<int>>{};
    for (var resource in ResourceType.values) {
      if (resource != ResourceType.none && resource != ResourceType.any) {
        resources[resource] = GameStateVar(game, '$playerId:${resource.toString()}', 0);
      }
    }
    for (var p in PartType.values) {
      parts[p] = ListState<Part>(game, '$playerId:$p:parts');
    }
    resourceStorage = 5;
    partStorage = 1;
    search = 3;
  }

  void _doParts(void Function(Part) fn) {
    for (var partList in parts.values) {
      for (var part in partList) {
        fn(part);
      }
    }
  }

  void resetPartActivations() {
    _doParts((part) => part.activated.reinitialize(false));
    _doParts((part) => part.ready.reinitialize(false));
  }

  int partCount() {
    var ret = 0;
    _doParts((part) => ret++);
    return ret;
  }

  int resourceCount() {
    var ret = 0;
    resources.forEach((key, value) {
      if (key != ResourceType.any && key != ResourceType.none) {
        ret += value.value;
      }
    });
    return ret;
  }

  void buyPart(Part part, List<ResourceType> payment) {
    parts[part.partType].add(part);
    for (var resource in payment) {
      if (resources[resource].value < 1) throw ArgumentError('can\'t afford part.');
      resources[resource].value = resources[resource].value - 1;
      game.addToWell(resource);
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

  bool get isGameEnded => parts.length > 15 || _level3Parts > 3;

  int get score {
    var ret = 0;
    _doParts((part) => ret += part.vp);
    ret += vpChits;
    return ret;
  }

  void giveVpChit() => _vpChits.value = _vpChits.value + 1;

  bool get hasResourceStorageSpace => resourceStorage > resourceCount();

  bool get hasPartStorageSpace => partStorage > savedParts.length;

  bool hasResource(ResourceType resourceType) => resources[resourceType].value > 0;

  void storeResource(ResourceType resource) {
    resources[resource].value = resources[resource].value + 1;
  }

  void removeResource(ResourceType resource) {
    resources[resource].value = resources[resource].value - 1;
  }

  bool canAfford(Part part) {
    if (part.resource == ResourceType.any && part.cost <= resourceCount()) {
      return true;
    } else {
      return part.cost <= resources[part.resource].value;
    }
  }

  bool canConvert(ResourceType resourceType) {
    for (var part in parts[PartType.converter]) {
      if (!part.activated.value && (part as ConverterPart).canConvert(resourceType)) {
        return true;
      }
    }
    return false;
  }

  bool isInStorage(Part part) {
    return savedParts.contains(part);
  }
}
