import 'dart:math';
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
  // maxResources is a cache, so it can be null.
  ResourcePool maxResources;

  int get vpChits => _vpChits.value;

  PlayerData(this.game, this.id)
      : parts = MapState<PartType, ListState<Part>>(game, '$id:parts'),
        savedParts = ListState<Part>(game, '$id:savedParts'),
        _vpChits = GameStateVar<int>(game, '$id:vpChits', 0),
        resources = <ResourceType, GameStateVar<int>>{},
        maxResources = null {
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

  PlayerData._fromJsonHelper(this.game, this.id, this.parts, this._vpChits, this.resources, this.savedParts) : maxResources = null {
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

  void buyPart(Part part) {
    //}, List<ResourceType> payment) {
    parts[part.partType].add(part);
    // for (var resource in payment) {
    //   resources[resource].value = resources[resource].value - 1;
    //   game.addToWell(resource);
    // }
    invalidateMaxResources();
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
    invalidateMaxResources();
  }

  void removeResource(ResourceType resource) {
    resources[resource].value = resources[resource].value - 1;
    invalidateMaxResources();
  }

  void updateMaxResources() {
    //maxResources = getMaxResources();
    throw UnimplementedError();
  }

  void invalidateMaxResources() {
    maxResources = null;
  }

  List<SpendHistory> getPayments(Part part) {
    return CalcResources.getPayments(part.cost, part.resource, ResourcePool.fromResources(resources), CalcResources.makeProductList(parts));
  }

  bool canAfford(Part part, int discount, Map<ResourceType, GameStateVar<int>> convertedResources) {
    if (maxResources == null) {
      maxResources = CalcResources.getMaxResources(ResourcePool.fromResources(resources), CalcResources.makeProductList(parts));
    }
    if (part.resource == ResourceType.any) {
      return (part.cost - discount) <= maxResources.count(part.resource) + ResourcePool.fromResources(convertedResources).getResourceCount();
    } else {
      return (part.cost - discount) <= maxResources.count(part.resource) + convertedResources[part.resource].value;
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

  // Tuple2<List<ConvertProduct>, List<DoubleResourceProduct>> _getMatchingProducts(List<Product> products, ResourceType rt) {
  //   var cvList = <ConvertProduct>[];
  //   var dblList = <DoubleResourceProduct>[];
  //   for (var product in products) {
  //     if (product.productType == ProductType.convert) {
  //       var p = product as ConvertProduct;
  //       if (p.source == rt || rt == ResourceType.any) {
  //         cvList.add(p);
  //       }
  //     } else if (product.productType == ProductType.doubleResource) {
  //       var p = product as DoubleResourceProduct;
  //       if (p.resourceType == rt || rt == ResourceType.any) {
  //         dblList.add(p);
  //       }
  //     }
  //   }
  //   return Tuple2(cvList, dblList);
  // }

  // // for each ResourceType, calc the max available, using available converters
  // // returns the max attainable for each type, and a list (in order) of the Products
  // // used to generate the result.  As there may be more than one way to get a total, all
  // // ways to get the total are returned.
  // // if [needed] is specified, then stop the search after getting that many resources
  // Map<ResourceType, Tuple2<int, List<List<Product>>>> getMaxResources() {
  //   return _getMaxResourcesI();
  // }

  // Map<ResourceType, Tuple2<int, List<List<Product>>>> _getMaxResourcesI() {
  //   var max = <ResourceType, int>{};
  //   var sourcePool = <ResourceType, int>{};
  //   for (var resourceType in resources.keys) {
  //     if (resourceType == ResourceType.none) continue;
  //     // set up our initial pool
  //     //if (resourceType == ResourceType.any || resourceType == ResourceType.none) continue;
  //     if (needed == 0) {
  //       max[resourceType] = Tuple2<int, List<List<Product>>>(resources[resourceType].value, <List<Product>>[]);
  //     } else {
  //       max[resourceType] = Tuple2<int, List<List<Product>>>(0, <List<Product>>[]);
  //     }
  //     sourcePool[resourceType] = resources[resourceType].value;
  //   }

  //   // fix the ResourceType.any max
  //   max[ResourceType.any] = Tuple2<int, List<List<Product>>>(_getResourceCount(sourcePool), <List<Product>>[]);

  //   // make a Set of available converters
  //   var products = <Product>[];
  //   for (var part in parts[PartType.converter]) {
  //     if (!part.ready.value) continue;
  //     for (var index = 0; index < part.products.length; ++index) {
  //       if (!part.products[index].activated.value) {
  //         products.add(part.products[index]);
  //       }
  //     }
  //   }

  //   if (needed > 0) {
  //     // we are looking for specific ways to get to a total,
  //     //so we'll add in picking in resources we already have
  //     var spenders = <SpendResourceProduct>[];
  //     if (needed > 0) {
  //       for (var rt in resources.keys) {
  //         if (rt == ResourceType.any || rt == ResourceType.none) continue;
  //         if (rt == neededResource || neededResource == ResourceType.any) {
  //           for (var count = 0; count < resources[rt].value; ++count) {
  //             spenders.add(SpendResourceProduct(game, rt));
  //           }
  //         }
  //       }
  //     }
  //     _findNeededResources(max, products, spenders, sourcePool, <Product>[], needed, neededResource);
  //   } else {
  //     _findMaxResources(max, products, sourcePool, _createResourcePool(), <Product>[], needed, neededResource, false);
  //   }

  //   return max;
  // }

  // Map<ResourceType, int> _createResourcePool() {
  //   return <ResourceType, int>{ResourceType.heart: 0, ResourceType.spade: 0, ResourceType.diamond: 0, ResourceType.club: 0};
  // }

  // List<List<Product>> getSpendOptions(ResourceType resource, int needed) {
  //   var max = _getMaxResourcesI(needed, resource);
  //   return max[resource].item2;
  // }

  // int _getResourceCount(Map<ResourceType, int> pool) {
  //   var total = 0;
  //   for (var rt in ResourceType.values) {
  //     if (rt == ResourceType.any || rt == ResourceType.none) continue;
  //     total += pool[rt];
  //   }
  //   return total;
  // }

  // void _calcNeeded(List<Product> products, ResourceType neededResource, int needed) {
  //   // first, do we have enough to buy outright?
  //   //var results = <List<Tuple2<List<
  //   var matchingProds = _getMatchingProducts(products, ResourceType.any);
  //   var availConv = <ConvertProduct>[];
  //   var availDbl = <DoubleResourceProduct>[];
  //   for (var conv in matchingProds.item1) {
  //     if (resources[conv.source].value > 0) {
  //       availConv.add(conv);
  //     }
  //   }
  //   for (var dbl in matchingProds.item2) {
  //     if (dbl.resourceType == neededResource) {
  //       availDbl.add(dbl);
  //     } else {
  //       var convs = _getMatchingProducts(products, dbl.resourceType);
  //       if (convs.item1.length >= 2 && availConv.length >= 3) {
  //         // there's at least 2 matching converters to use our output
  //         availDbl.add(dbl);
  //       }
  //     }
  //   }
  //   if (resources[neededResource].value >= needed) {}
  // }

  // void _try2(List<List<Tuple2<Product, bool>>> results, List<Product> conv, Map<ResourceType, int> pool, List<Tuple2<Product, bool>> prodHistory,
  //     List<ResourceType> resourceHistory, int needed, ResourceType neededResource) {
  //   if (pool[neededResource] >= needed) {
  //     return;
  //   }
  //   // for each resource, see if we can use it
  //   for (var resource in pool.keys) {
  //     var prods = _getMatchingProducts(conv, resource);
  //     if (resource == neededResource) {
  //       for (var count = 0; count < resources[resource].value; ++count) {
  //         while (prods.item2.isNotEmpty) {
  //           // use doublers
  //           var p = prods.item2.last;
  //           prods.item2.removeLast();
  //           conv.remove(p);
  //           pool[resource]++;
  //           var h2 = List<Tuple2<Product, bool>>.of(prodHistory);
  //           h2.add(Tuple2<Product, bool>(p, true));
  //           if (pool[resource] == needed) {
  //             results.add(h2);
  //             break;
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  // void _findNeededResources(Map<ResourceType, Tuple2<int, List<List<Product>>>> max, List<Product> conv, List<SpendResourceProduct> spenders, Map<ResourceType, int> inputPool,
  //     List<Product> history, int needed, ResourceType neededResource) {
  //   var outputPool = _createResourcePool();
  //   max[neededResource] = Tuple2<int, List<List<Product>>>(2, <List<Product>>[]);
  //   _findMaxResources(max, conv, inputPool, outputPool, history, needed, neededResource, false);
  //   for (var cv in spenders) {
  //     if (outputPool[neededResource] == needed) break;
  //     if (neededResource == ResourceType.any || neededResource == cv.resourceType) {
  //       // we have a matching resource, so use it
  //       var history2 = List<Product>.of(history);
  //       history2.add(cv);
  //       var ip2 = Map<ResourceType, int>.of(inputPool);
  //       ip2[cv.resourceType]--;
  //       outputPool[cv.resourceType]++;
  //       if (outputPool[neededResource] == needed) {
  //         max[cv.resourceType].item2.add(history2);
  //         break;
  //       }
  //       // now try everything else
  //       _findMaxResources(max, conv, ip2, _createResourcePool(), history2, needed - outputPool[cv.resourceType], neededResource, false);
  //     }
  //   }
  // }

  // // recursively try all permutations of products
  // void _findMaxResources(Map<ResourceType, Tuple2<int, List<List<Product>>>> max, List<Product> conv, Map<ResourceType, int> inputPool, Map<ResourceType, int> outputPool,
  //     List<Product> history, int needed, ResourceType neededResource, bool prevConverter) {
  //   for (var c in conv) {
  //     if (c.productType == ProductType.convert) {
  //       //if (prevConverter) continue; // don't convert something twice in a row
  //       var cv = c as ConvertProduct;
  //       if (inputPool[cv.source] > 0) {
  //         // we have a matching resource, so use it
  //         for (var rt in ResourceType.values) {
  //           if (rt == cv.source || rt == ResourceType.any || rt == ResourceType.none) continue;
  //           //if (needed > 0 && rt != neededResource) continue;
  //           var history2 = List<Product>.of(history);
  //           var newProd = ConvertProduct(cv.part.ready.game, cv.source, rt);
  //           newProd.part = cv.part;
  //           history2.add(newProd);
  //           var ip2 = Map<ResourceType, int>.of(inputPool);
  //           var op2 = Map<ResourceType, int>.of(outputPool);
  //           ip2[cv.source]--;
  //           op2[rt]++;
  //           var conv2 = List<Product>.of(conv);
  //           conv2.remove(c);
  //           if (needed == 0) {
  //             // just finding the max
  //             if (max[rt].item1 < op2[rt] + ip2[rt]) {
  //               max[rt] = Tuple2<int, List<List<Product>>>(op2[rt] + ip2[rt], <List<Product>>[history2]);
  //             } else if (max[rt].item1 == op2[rt] + ip2[rt]) {
  //               max[rt].item2.add(history2);
  //             }
  //           } else {
  //             if (neededResource == ResourceType.any) {
  //               var total = _getResourceCount(op2);
  //               if (total == needed) {
  //                 max[ResourceType.any].item2.add(history2);
  //               }
  //             } else if (op2[neededResource] == needed) {
  //               max[rt].item2.add(history2);
  //             }
  //           }
  //           if (needed == 0 || op2[neededResource] < needed) {
  //             var avail = op2[rt];
  //             _findMaxResources(max, conv2, ip2, op2, history2, needed, neededResource, true);
  //             if (op2[rt] == avail) {}
  //           }
  //         }
  //       }
  //     } else if (c.productType == ProductType.doubleResource) {
  //       var cv = c as DoubleResourceProduct;
  //       if (inputPool[cv.resourceType] > 0 || outputPool[cv.resourceType] > 0) {
  //         if (prevConverter) {
  //           if ((history.last as ConvertProduct).dest != cv.resourceType) {
  //             // if we previously converted something, we only want to double that
  //             continue;
  //           }
  //         }
  //         // skip if we are targeting a number and we already have enough
  //         //if (needed > 0 && (pool[cv.resourceType] >= needed)) continue;
  //         // we have a matching resource, so use it
  //         var history2 = List<Product>.of(history);
  //         history2.add(c);
  //         var ip2 = Map<ResourceType, int>.of(inputPool);
  //         var op2 = Map<ResourceType, int>.of(outputPool);
  //         if (op2[cv.resourceType] > 0) {
  //           op2[cv.resourceType]++;
  //         } else if (ip2[cv.resourceType] > 0) {
  //           ip2[cv.resourceType]--;
  //           op2[cv.resourceType] += 2;
  //         }
  //         //var sp2 = Map<ResourceType, int>.of(sourcePool);
  //         // if (pool[cv.resourceType] > 0) {
  //         //   var prevSpend = history2.firstWhere((product) => product is SpendResourceProduct && product.resourceType == cv.resourceType, orElse: () => null);
  //         //   if (prevSpend != null) {
  //         //     // we spent a resource, but we could've just directly used it, so pretend we aren't getting from the pool
  //         //     history2.remove(prevSpend);
  //         //   }
  //         //   p2[cv.resourceType]++;
  //         // } else {
  //         //  sp2[cv.resourceType]--;
  //         //  p2[cv.resourceType] += 2;
  //         //}
  //         var conv2 = List<Product>.of(conv);
  //         conv2.remove(c);
  //         if (needed == 0) {
  //           if (max[cv.resourceType].item1 < op2[cv.resourceType] + ip2[cv.resourceType]) {
  //             max[cv.resourceType] = Tuple2<int, List<List<Product>>>(op2[cv.resourceType] + ip2[cv.resourceType], <List<Product>>[history2]);
  //           } else if (max[cv.resourceType].item1 == op2[cv.resourceType] + ip2[cv.resourceType]) {
  //             max[cv.resourceType].item2.add(history2);
  //           }
  //           var total = _getResourceCount(op2) + _getResourceCount(ip2);
  //           if (max[ResourceType.any].item1 < total) {
  //             max[ResourceType.any] = Tuple2<int, List<List<Product>>>(total, <List<Product>>[history2]);
  //           } else if (max[ResourceType.any].item1 == total) {
  //             max[ResourceType.any].item2.add(history2);
  //           }
  //         } else {
  //           if (op2[neededResource] == needed) {
  //             max[neededResource].item2.add(history2);
  //           }
  //         }
  //         if (needed != 0 && op2[cv.resourceType] < needed) {
  //           _findMaxResources(max, conv2, ip2, op2, history2, needed, neededResource, false);
  //         }
  //       }
  //     } else {
  //       throw InvalidOperationError("found non converter type when counting resources");
  //     }
  //   }
  // }

  bool isInStorage(Part part) {
    return savedParts.contains(part);
  }
}
