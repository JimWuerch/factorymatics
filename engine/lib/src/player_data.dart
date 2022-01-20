import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:engine/src/part/converter_part.dart';
import 'package:tuple/tuple.dart';

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
        allP.add("${part.id}:${part.getPartSerializeString()}");
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
    for (var partCode in partsList) {
      var i = partCode.indexOf(':');
      var partId = partCode.substring(0, i);
      var p = game.allParts[partId];
      p.setPartFromSerializeString(partCode.substring(i + 1));
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

  // for each ResourceType, calc the max available, using available converters
  // returns the max attainable for each type, and a list (in order) of the Products
  // used to generate the result.  As there may be more than one way to get a total, all
  // ways to get the total are returned.
  // if [needed] is specified, then stop the search after getting that many resources
  Map<ResourceType, Tuple2<int, List<List<Product>>>> getMaxResources(int needed) {
    var max = <ResourceType, Tuple2<int, List<List<Product>>>>{};
    var pool = <ResourceType, int>{};
    for (var resourceType in resources.keys) {
      if (resourceType == ResourceType.none) continue;
      // set up our initial pool
      //if (resourceType == ResourceType.any || resourceType == ResourceType.none) continue;
      max[resourceType] = Tuple2<int, List<List<Product>>>(resources[resourceType].value, <List<Product>>[]);
      pool[resourceType] = resources[resourceType].value;
    }

    // fix the ResourceType.any max
    max[ResourceType.any] = Tuple2<int, List<List<Product>>>(_getResourceCount(pool), <List<Product>>[]);

    // make a Set of available converters
    var products = <Product>{};
    for (var part in parts[PartType.converter]) {
      if (!part.ready.value) continue;
      for (var index = 0; index < part.products.length; ++index) {
        if (!part.products[index].activated.value) {
          products.add(part.products[index]);
        }
      }
    }

    _findMaxResources(max, products, pool, <Product>[], needed);

    return max;
  }

  int _getResourceCount(Map<ResourceType, int> pool) {
    var total = 0;
    for (var rt in ResourceType.values) {
      if (rt == ResourceType.any || rt == ResourceType.none) continue;
      total += pool[rt];
    }
    return total;
  }

  // recursively try all permutations of products
  void _findMaxResources(Map<ResourceType, Tuple2<int, List<List<Product>>>> max, Set<Product> conv, Map<ResourceType, int> pool, List<Product> history, int needed) {
    for (var c in conv) {
      if (c.productType == ProductType.convert) {
        var cv = c as ConvertProduct;
        if (pool[cv.source] > 0) {
          // we have a matching resource, so use it
          var history2 = List<Product>.of(history);
          history2.add(c);
          pool[cv.source]--;
          for (var rt in ResourceType.values) {
            if (rt == cv.source || rt == ResourceType.any || rt == ResourceType.none) continue;
            var p2 = Map<ResourceType, int>.of(pool);
            p2[rt]++;
            var conv2 = Set<Product>.of(conv);
            conv2.remove(c);
            if (max[rt].item1 < p2[rt]) {
              max[rt] = Tuple2<int, List<List<Product>>>(p2[rt], <List<Product>>[history2]);
            } else if (max[rt].item1 == p2[rt]) {
              max[rt].item2.add(history2);
            }
            if (needed != 0 && p2[rt] < needed) {
              _findMaxResources(max, conv2, p2, history2, needed);
            }
          }
        }
      } else if (c.productType == ProductType.doubleResource) {
        var cv = c as DoubleResourceProduct;
        if (pool[cv.resourceType] > 0) {
          // we have a matching resource, so use it
          var history2 = List<Product>.of(history);
          history2.add(c);
          pool[cv.resourceType]--;
          var p2 = Map<ResourceType, int>.of(pool);
          p2[cv.resourceType] += 2;
          var conv2 = Set<Product>.of(conv);
          conv2.remove(c);
          if (max[cv.resourceType].item1 < p2[cv.resourceType]) {
            max[cv.resourceType] = Tuple2<int, List<List<Product>>>(p2[cv.resourceType], <List<Product>>[history2]);
          } else if (max[cv.resourceType].item1 == p2[cv.resourceType]) {
            max[cv.resourceType].item2.add(history2);
          }
          var total = _getResourceCount(p2);
          if (max[ResourceType.any].item1 < total) {
            max[ResourceType.any] = Tuple2<int, List<List<Product>>>(total, <List<Product>>[history2]);
          } else if (max[ResourceType.any].item1 == p2[ResourceType.any]) {
            max[ResourceType.any].item2.add(history2);
          }
          if (needed != 0 && p2[cv.resourceType] < needed) {
            _findMaxResources(max, conv2, p2, history2, needed);
          }
        }
      } else {
        throw InvalidOperationError("found non converter type when counting resources");
      }
    }
  }

  bool isInStorage(Part part) {
    return savedParts.contains(part);
  }
}
