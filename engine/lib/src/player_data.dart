import 'package:engine/engine.dart';
import 'package:engine/src/part/converter_part.dart';

class PlayerData {
  static const int baseResourceStorage = 5;
  static const int basePartStorage = 1;
  static const int baseSearch = 3;

  final String id;
  final MapState<PartType, ListState<Part>> parts;
  final GameStateVar<int> _vpChits;
  final Map<ResourceType, GameStateVar<int>> resources;
  final Game game;
  final ListState<Part> savedParts;

  int get vpChits => _vpChits.value;

  PlayerData(this.game, this.id)
      : parts = MapState<PartType, ListState<Part>>(game, '$id:parts'),
        savedParts = ListState<Part>(game, '$id:savedParts'),
        _vpChits = GameStateVar<int>(game, '$id:vpChits', 0),
        resources = <ResourceType, GameStateVar<int>>{} {
    initResourceMap(game, resources, id);
    _initParts(parts);
  }

  static void initResourceMap(Game game, Map<ResourceType, GameStateVar<int>> resources, String label) {
    for (var resource in ResourceType.values) {
      if (resource != ResourceType.none && resource != ResourceType.any) {
        resources[resource] = GameStateVar(game, '$label:${resource.toString()}', 0);
      }
    }
  }

  void _initParts(MapState<PartType, ListState<Part>> parts) {
    for (var p in PartType.values) {
      parts[p] = ListState<Part>(game, '$id:$p:parts');
    }
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{};

    if (game.isAuthoritativeSave) {
      ret['id'] = id;
    } else {
      ret['id'] = game.playerService.getPlayer(id).name;
    }
    var allP = <String>[];
    for (var plist in parts.values) {
      for (var part in plist) {
        allP.add(part.id);
      }
    }
    ret['parts'] = allP;
    ret['vp'] = _vpChits.value;
    ret['res'] = resourceMapStateToString(resources);
    var savedP = <String>[];
    for (var part in savedParts) {
      savedP.add(part.id);
    }
    ret['saved'] = savedP;

    return ret;
  }

  PlayerData._fromJsonHelper(this.game, this.id, this.parts, this._vpChits, this.resources, this.savedParts) {
    initResourceMap(game, resources, id);
    _initParts(parts);
  }

  factory PlayerData.fromJson(Game game, Map<String, dynamic> json) {
    var id = json['id'] as String;
    var parts = MapState<PartType, ListState<Part>>(game, '$id:parts');
    var vp = GameStateVar<int>(game, '$id:vpChits', json['vp'] as int);
    var resources = <ResourceType, GameStateVar<int>>{};
    var savedParts = ListState<Part>(game, '$id:savedParts');

    var ret = PlayerData._fromJsonHelper(game, id, parts, vp, resources, savedParts);

    var savedP = listFromJson<String>(json['saved']);
    for (var part in savedP) {
      var p = game.allParts[part];
      ret.savedParts.add(p);
    }

    var partsList = listFromJson<String>(json['parts']);
    for (var part in partsList) {
      var p = game.allParts[part];
      ret.parts[p.partType].add(p);
    }

    var res = stringToResourceMap(json['res'] as String);
    ret.resources[ResourceType.heart].reinitialize(res[ResourceType.heart]);
    ret.resources[ResourceType.club].reinitialize(res[ResourceType.club]);
    ret.resources[ResourceType.spade].reinitialize(res[ResourceType.spade]);
    ret.resources[ResourceType.diamond].reinitialize(res[ResourceType.diamond]);

    return ret;
  }

  void _doParts(void Function(Part) fn) {
    for (var partList in parts.values) {
      for (var part in partList) {
        fn(part);
      }
    }
  }

  void resetPartActivations() {
    _doParts((part) => part.resetActivations());
    _doParts((part) => part.ready.reinitialize(false));
  }

  int partCount() {
    var ret = 0;
    _doParts((part) => ret++);
    return ret;
  }

  int get resourceStorage {
    var ret = baseResourceStorage;
    _doParts((part) {
      if (part is EnhancementPart) {
        ret += part.resourceStorage;
      }
    });
    return ret;
  }

  int get partStorage {
    var ret = basePartStorage;
    _doParts((part) {
      if (part is EnhancementPart) {
        ret += part.partStorage;
      }
    });
    return ret;
  }

  int get search {
    var ret = baseSearch;
    _doParts((part) {
      if (part is EnhancementPart) {
        ret += part.search;
      }
    });
    return ret;
  }

  int get level3PartCount {
    var ret = 0;
    _doParts((part) {
      if (part.level == 2) ret++;
    });
    return ret;
  }

  bool get canStore {
    for (var part in parts[PartType.enhancement]) {
      if (part is DisallowStorePart) return false;
    }
    return true;
  }

  bool get canSearch {
    for (var part in parts[PartType.enhancement]) {
      if (part is DisallowSearchPart) return false;
    }
    return true;
  }

  int get constructFromStoreDiscount {
    var discount = 0;
    for (var part in parts[PartType.enhancement]) {
      if (part is ConstructFromStoreDiscountPart) {
        discount += part.constructFromStoreDiscount;
      }
    }
    return discount;
  }

  int get constructFromSearchDiscount {
    var discount = 0;
    for (var part in parts[PartType.enhancement]) {
      if (part is ConstructFromSearchDiscountPart) {
        discount += part.constructFromSearchDiscount;
      }
    }
    return discount;
  }

  int get constructLevel2Discount {
    var discount = 0;
    for (var part in parts[PartType.enhancement]) {
      if (part is Level2ConstructDiscountPart) {
        discount += part.level2ConstructDiscount;
      }
    }
    return discount;
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
      resources[resource].value = resources[resource].value - 1;
      game.addToWell(resource);
    }
  }

  void savePart(Part part) {
    if (savedParts.length >= partStorage) throw ArgumentError('can\'t save part, no space');
    savedParts.add(part);
  }

  void unsavePart(Part part) {
    if (!savedParts.contains(part)) throw ArgumentError('can\'t unsave part.  Part not in storage.');
    savedParts.remove(part);
  }

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

  bool canAfford(Part part, int discount) {
    if (part.resource == ResourceType.any && (part.cost - discount) <= resourceCount()) {
      return true;
    } else {
      return (part.cost - discount) <= resources[part.resource].value;
    }
  }

  bool canConvert(ResourceType resourceType) {
    for (var part in parts[PartType.converter]) {
      if (part is ConverterPart) {
        if (!part.products[0].activated.value && part.canConvert(resourceType)) {
          return true;
        }
      } else if (part is MultipleConverterPart) {
        for (var i = 0; i < MultipleConverterPart.numberOfParts; ++i) {
          if (!part.products[i].activated.value && part.canConvert(i, resourceType)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isInStorage(Part part) {
    return savedParts.contains(part);
  }
}
