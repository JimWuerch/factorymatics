// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:typed_data';

import 'package:engine/engine.dart';

class UsedProduct {
  final bool usedSource;
  final ConverterBaseProduct product;
  final int id;
  ResourceType get source => product.sourceResource;

  // ignore: avoid_positional_boolean_parameters
  UsedProduct(this.product, this.usedSource, this.id);

  UsedProduct.of(UsedProduct src) : this(src.product, src.usedSource, src.id);

  @override
  String toString() {
    if (product.productType == ProductType.convert) {
      var p = product as ConvertProduct;
      return 'Converted ${p.source.name} to ${p.dest.name} from ${usedSource ? 'source' : 'pool'}';
    } else if (product.productType == ProductType.doubleResource) {
      return 'Doubled ${source.name} from ${usedSource ? 'source' : 'pool'}';
    } else if (product.productType == ProductType.spend) {
      return 'Spent ${source.name} from source';
    } else {
      return 'Unknown product type: ${product.runtimeType}';
    }
  }

  void dump() {
    print(toString());
  }
}

class ResourcePool {
  final Int8List _resources;

  ResourcePool() : _resources = _createResourcePool();

  ResourcePool.fromResources(Map<ResourceType, GameStateVar<int>> src) : _resources = _createResourcePool() {
    for (var resourceType in src.keys) {
      if (resourceType == ResourceType.none) continue;
      set(resourceType, src[resourceType].value);
    }
  }

  ResourcePool.of(ResourcePool src) : _resources = Int8List.fromList(src._resources);

  int count(ResourceType rt) => _resources[rt.index];
  void add1(ResourceType rt) => _resources[rt.index]++;
  void sub1(ResourceType rt) {
    if (_resources[rt.index] == 0) {
      throw InvalidOperationError('No resource');
    } else {
      _resources[rt.index]--;
    }
  }

  void set(ResourceType rt, int value) {
    if (value < 0) {
      throw InvalidOperationError('Negative value set');
    }
    _resources[rt.index] = value;
  }

  int getResourceCount() {
    var total = 0;
    for (var rt in ResourceType.values) {
      if (rt == ResourceType.any || rt == ResourceType.none) continue;
      total += _resources[rt.index];
    }
    return total;
  }

  List<ResourceType> toList() {
    var ret = <ResourceType>[];
    for (var rt in ResourceType.values) {
      if (rt == ResourceType.none || rt == ResourceType.any) continue;
      for (var i = 0; i < _resources[rt.index]; ++i) {
        ret.add(rt);
      }
    }
    return ret;
  }

  static Int8List _createResourcePool() {
    return Int8List(6); // ResourceType.values.length
    // return <ResourceType, int>{
    //   ResourceType.heart: 0,
    //   ResourceType.spade: 0,
    //   ResourceType.diamond: 0,
    //   ResourceType.club: 0
    // };
  }

  @override
  String toString() {
    if (_resources[ResourceType.any.index] > 0) {
      return 'heart:${_resources[ResourceType.heart.index]} spade:${_resources[ResourceType.spade.index]} diamond: ${_resources[ResourceType.diamond.index]} club: ${_resources[ResourceType.club.index]} any: ${_resources[ResourceType.any.index]}';
    }
    return 'heart:${_resources[ResourceType.heart.index]} spade:${_resources[ResourceType.spade.index]} diamond: ${_resources[ResourceType.diamond.index]} club: ${_resources[ResourceType.club.index]}';
  }
}

class SpendHistory {
  final List<UsedProduct> history;

  SpendHistory() : history = <UsedProduct>[];

  SpendHistory.fromHistory(List<UsedProduct> src) : history = List<UsedProduct>.of(src);

  SpendHistory.of(SpendHistory src) : this.fromHistory(src.history);

  void add(UsedProduct p) => history.add(p);

  UsedProduct get last => history.last;

  int get length => history.length;

  ResourcePool getCost() {
    var pool = ResourcePool();
    for (var prod in history) {
      if (prod.usedSource) {
        pool.add1(prod.source);
      }
    }
    return pool;
  }

  ResourcePool getOutput() {
    var pool = ResourcePool();
    for (var prod in history) {
      if (prod.product is SpendResourceProduct) {
        pool.add1(prod.product.sourceResource);
      } else if (prod.product is ConvertProduct) {
        if (!prod.usedSource) {
          pool.sub1(prod.product.sourceResource);
        }
        pool.add1((prod.product as ConvertProduct).dest);
      } else if (prod.product is DoubleResourceProduct) {
        if (prod.usedSource) {
          pool.add1(prod.product.sourceResource);
        }
        pool.add1(prod.product.sourceResource);
      } else {
        throw InvalidOperationError('Unknown product in SpendHistory');
      }
    }
    return pool;
  }

  String id() {
    var ret = 0;
    var spenders = <String>[];
    for (var prod in history) {
      if (prod.product is SpendResourceProduct) {
        spenders.add(prod.product.sourceResource.index.toString());
      } else {
        ret += prod.id;
      }
    }
    spenders.sort();
    return '${spenders.join()}:$ret';
  }

  void dump() {
    var cost = <ResourceType>[];
    for (var h in history) {
      if (h.usedSource) {
        cost.add(h.source);
      }
      h.dump();
    }
    var sb = StringBuffer("Cost: ");
    for (var i = 0; i < cost.length; ++i) {
      if (i != 0) sb.write(',');
      sb.write(cost[i].name);
    }
    print(sb.toString());
  }
}

class _AnyToAnyProduct extends ConvertProduct {
  final ConvertProduct src;
  // instances are so we can have separate id's for each source type, so the dedup still works
  Map<ResourceType, ConvertProduct> instances;
  _AnyToAnyProduct(this.src) : super(src.part?.ready?.game, src.source, src.dest) {
    part = src.part;
    prodIndex = src.prodIndex;
    instances = <ResourceType, ConvertProduct>{};
    for (var rt in ResourceType.values) {
      if (rt == ResourceType.any || rt == ResourceType.none) continue;
      var newProd = ConvertProduct(null, rt, ResourceType.any);
      newProd.part = src.part;
      newProd.prodIndex = src.prodIndex;
      if (src.part == null) {
        print('hmmm');
      }
      newProd.prodIndex = src.prodIndex;
      instances[rt] = newProd;
      CalcResources._idToProd[1 << CalcResources.prodCount] = newProd;
      CalcResources._prodIds[newProd] = 1 << CalcResources.prodCount;
      CalcResources.prodCount++;
    }
  }
}

class CalcResources {
  static final Map<ConverterBaseProduct, int> _prodIds = <ConverterBaseProduct, int>{};
  static final Map<int, ConverterBaseProduct> _idToProd = <int, ConverterBaseProduct>{};
  static int prodCount = 0;

  // helper function for PlayerData usage
  static List<ConverterBaseProduct> makeProductList(MapState<PartType, ListState<Part>> parts) {
    // make a Set of available converters
    var products = <ConverterBaseProduct>[];
    for (var part in parts[PartType.converter]) {
      if (!part.ready.value) continue;
      for (var index = 0; index < part.products.length; ++index) {
        if (!part.products[index].activated.value) {
          // if (part is MultipleConverterPart) {
          //   products.add(part.converters[0].products[0] as ConverterBaseProduct);
          //   products.add(part.converters[1].products[0] as ConverterBaseProduct);
          // } else {
          products.add(part.products[index] as ConverterBaseProduct);
          // }
        }
      }
    }
    return products;
  }

  static List<SpendHistory> getPayments(
      int needed, ResourceType neededResource, ResourcePool sourcePool, List<ConverterBaseProduct> products) {
    var paths = <SpendHistory>[];
    var anyToAny = <_AnyToAnyProduct>[];

    if (sourcePool.getResourceCount() == 0) return paths;

    // create our mapping of converters to identifiers so we can de-dup later
    for (var prod in products) {
      if (prod is ConvertProduct && prod.source == ResourceType.any) {
        anyToAny.add(_AnyToAnyProduct(prod));
      } else {
        _idToProd[1 << prodCount] = prod;
        _prodIds[prod] = 1 << prodCount;
        prodCount++;
      }
    }
    // remove the any to any prods and add in our proxies
    for (var prod in anyToAny) {
      products.remove(prod.src);
    }
    products.addAll(anyToAny);

    if (needed > 0) {
      // we are looking for specific ways to get to a total,
      //so we'll add in picking in resources we already have
      var spenders = <SpendResourceProduct>[];
      if (needed > 0) {
        for (var rt in ResourceType.values) {
          if (rt == ResourceType.any || rt == ResourceType.none) continue;
          if (rt == neededResource || neededResource == ResourceType.any) {
            for (var count = 0; count < sourcePool.count(rt); ++count) {
              spenders.add(SpendResourceProduct(null, rt));
              _idToProd[1 << prodCount] = spenders.last;
              _prodIds[spenders.last] = 1 << prodCount;
              prodCount++;
            }
          }
        }
      }
      _getSpendPaths(paths, products, spenders, sourcePool, SpendHistory(), needed, neededResource, _prodIds);
    } else {
      _getConvertersPaths(
          paths, products, sourcePool, ResourcePool(), SpendHistory(), needed, neededResource, _prodIds);
    }

    // now de-dup paths
    var dedup = <String, SpendHistory>{};
    for (var path in paths) {
      dedup[path.id()] = path;
    }

    _idToProd.clear();
    _prodIds.clear();

    return dedup.values.toList();
  }

  static void _getSpendPaths(
    List<SpendHistory> paths,
    List<ConverterBaseProduct> conv,
    List<SpendResourceProduct> spenders,
    ResourcePool inputPool,
    SpendHistory history,
    int needed,
    ResourceType neededResource,
    Map<ConverterBaseProduct, int> prodIds,
  ) {
    if (needed == 0) {
      return;
    }
    _getConvertersPaths(paths, conv, inputPool, ResourcePool(), history, needed, neededResource, prodIds);
    // for ResourceType.any we need to try every permutation of the spending order
    if (neededResource == ResourceType.any) {
      for (var spender in spenders) {
        if (neededResource != ResourceType.any && neededResource != spender.resourceType) continue;
        var history2 = SpendHistory.of(history);
        var ip2 = ResourcePool.of(inputPool);
        var sp2 = List<SpendResourceProduct>.of(spenders);
        history2.add(UsedProduct(spender, true, prodIds[spender]));
        sp2.remove(spender);
        ip2.sub1(spender.resourceType);
        if (needed - 1 == 0) {
          paths.add(history2);
        } else {
          _getSpendPaths(paths, conv, sp2, ip2, history2, needed - 1, neededResource, prodIds);
        }
      }
    } else {
      for (var rt in ResourceType.values) {
        if (rt == ResourceType.any || rt == ResourceType.none || inputPool.count(rt) == 0) continue;
        if (neededResource != ResourceType.any && neededResource != rt) continue;
        var history2 = SpendHistory.of(history);
        var ip2 = ResourcePool.of(inputPool);
        var currentSpenders = spenders.where((element) => element.resourceType == rt);
        // take all the matching spenders out of the list
        var sp2 = spenders.where((element) => element.resourceType != rt).toList();
        var resourceCount = 0;
        for (var cv in currentSpenders) {
          resourceCount++;
          history2.add(UsedProduct(cv, true, prodIds[cv]));
          ip2.sub1(cv.resourceType);
          if (needed - resourceCount == 0) {
            paths.add(history2);
            break;
          } else {
            _getSpendPaths(paths, conv, sp2, ip2, history2, needed - resourceCount, neededResource, prodIds);
          }
        }
      }
    }
  }

  // add spend products for all resources left in the inputPool
  // static void _addRemainingResources(
  //   List<SpendHistory> paths,
  //   ResourcePool inputPool,
  //   SpendHistory history,
  //   Map<ConverterBaseProduct, int> prodIds,
  //   List<SpendResourceProduct> spenders,
  // ) {
  //   var s2 = List<SpendResourceProduct>.of(spenders);
  //   // add spend products for all resources left in the inputPool
  //   for (var resource in inputPool.toList()) {
  //     var spender = s2.firstWhere((element) => element.sourceResource == resource);
  //     history.add(UsedProduct(spender, true, prodIds[spender]));
  //     s2.remove(spender);
  //   }
  // }

// recursively try all permutations of products
  static void _getConvertersPaths(
      List<SpendHistory> paths,
      List<ConverterBaseProduct> conv,
      ResourcePool inputPool,
      ResourcePool outputPool,
      SpendHistory history,
      int needed,
      ResourceType neededResource,
      Map<ConverterBaseProduct, int> prodIds) {
    for (var c in conv) {
      if (c.productType == ProductType.convert) {
        var cv = c as ConvertProduct;
        if (cv.source == ResourceType.any || (inputPool.count(cv.source) > 0 || outputPool.count(cv.source) > 0)) {
          // we have a matching resource, so use it
          for (var destRt in ResourceType.values) {
            if (destRt == cv.source || destRt == ResourceType.any || destRt == ResourceType.none) continue;
            //if (needed > 0 && rt != neededResource) continue;
            if (neededResource == ResourceType.any && ((needed - 1 <= outputPool.getResourceCount()))) {
              // we already have enough, no need to run a converter
              continue;
            }
            if (destRt != neededResource || neededResource == ResourceType.any) {
              // if there's no doublers that use this, then there's no reason to convert
              var found = false;
              for (var p in conv) {
                if (p.productType == ProductType.doubleResource && p.sourceResource == destRt) {
                  found = true;
                  break;
                }
              }
              if (!found) continue; // nothing can use this resource
            }
            for (var srcRt in ResourceType.values) {
              // we will try using every type as the "from". So for non any to any converters,
              // we will skip anything but the rt that matches what the converter source is
              if (srcRt == ResourceType.any ||
                  srcRt == ResourceType.none ||
                  srcRt == destRt ||
                  (cv.source != ResourceType.any && srcRt != cv.source)) continue;

              // this can happen for cv.source == ResourceType.any
              if (inputPool.count(srcRt) == 0 && outputPool.count(srcRt) == 0) continue;

              var history2 = SpendHistory.of(history);
              var newProd = ConvertProduct(null, srcRt, destRt);
              newProd.part = cv.part;
              newProd.prodIndex = cv.prodIndex;
              // if (cv.part == null) {
              //   print('hmmm');
              // }
              newProd.prodIndex = cv.prodIndex;
              var ip2 = ResourcePool.of(inputPool);
              var op2 = ResourcePool.of(outputPool);
              if (inputPool.count(srcRt) > 0) {
                ip2.sub1(srcRt);
                history2.add(UsedProduct(newProd, true,
                    cv.source == ResourceType.any ? prodIds[(c as _AnyToAnyProduct).instances[srcRt]] : prodIds[c]));
              } else {
                op2.sub1(srcRt);
                history2.add(UsedProduct(newProd, false,
                    cv.source == ResourceType.any ? prodIds[(c as _AnyToAnyProduct).instances[srcRt]] : prodIds[c]));
              }
              op2.add1(destRt);
              var conv2 = List<ConverterBaseProduct>.of(conv);
              conv2.remove(c);
              if (neededResource == ResourceType.any) {
                var total = op2.getResourceCount();
                if (total == needed) {
                  paths.add(history2);
                } else {
                  _getConvertersPaths(paths, conv2, ip2, op2, history2, needed, neededResource, prodIds);
                }
              } else if (op2.count(neededResource) == needed) {
                if (op2.getResourceCount() - op2.count(neededResource) != 0) {
                  // if we get here, we converted a resource we didn't need so, we'll abandon this path
                  continue;
                } else {
                  paths.add(history2);
                }
              } else {
                _getConvertersPaths(paths, conv2, ip2, op2, history2, needed, neededResource, prodIds);
              }
            }
          }
        }
      } else if (c.productType == ProductType.doubleResource) {
        var cv = c as DoubleResourceProduct;
        if (inputPool.count(cv.resourceType) > 0 || outputPool.count(cv.resourceType) > 0) {
          // we have a matching resource, so use it
          var history2 = SpendHistory.of(history);
          var ip2 = ResourcePool.of(inputPool);
          var op2 = ResourcePool.of(outputPool);
          if (op2.count(cv.resourceType) > 0) {
            op2.add1(cv.resourceType);
            history2.add(UsedProduct(c, false, prodIds[c]));
          } else if (ip2.count(cv.resourceType) > 0) {
            ip2.sub1(cv.resourceType);
            op2.add1(cv.resourceType);
            op2.add1(cv.resourceType);
            history2.add(UsedProduct(c, true, prodIds[c]));
          }
          var conv2 = List<ConverterBaseProduct>.of(conv);
          conv2.remove(c);

          if (neededResource == ResourceType.any) {
            var total = op2.getResourceCount(); // + (spenders != null ? ip2.getResourceCount() : 0);
            if (total == needed) {
              paths.add(history2);
              // // this will append spenders to the history we just saved
              // if (spenders != null) {
              //   _addRemainingResources(paths, ip2, history2, prodIds, spenders);
              // }
            } else {
              _getConvertersPaths(paths, conv2, ip2, op2, history2, needed, neededResource, prodIds);
            }
          } else if (op2.count(neededResource) == needed) {
            if (op2.getResourceCount() - op2.count(neededResource) != 0) {
              // if we get here, we converted a resource we didn't need so, we'll abandon this path
              continue;
            } else {
              paths.add(history2);
            }
          } else {
            _getConvertersPaths(paths, conv2, ip2, op2, history2, needed, neededResource, prodIds);
          }
        }
      } else {
        throw InvalidOperationError("found non converter type when counting resources");
      }
    }
  }

// for each ResourceType, calc the max available, using available converters
// returns the max attainable for each type
  static ResourcePool getMaxResources(ResourcePool sourcePool, List<ConverterBaseProduct> products) {
    return _getMaxResourcesI(sourcePool, products);
  }

  static ResourcePool _getMaxResourcesI(ResourcePool sourcePool, List<ConverterBaseProduct> products) {
    var max = ResourcePool.of(sourcePool);

    // fix the ResourceType.any max
    max.set(ResourceType.any, sourcePool.getResourceCount());

    _findMaxResources(max, products, sourcePool, ResourcePool());

    return max;
  }

// recursively try all permutations of products
  static void _findMaxResources(
      ResourcePool max, List<ConverterBaseProduct> conv, ResourcePool inputPool, ResourcePool outputPool) {
    for (var c in conv) {
      if (c.productType == ProductType.convert) {
        var cv = c as ConvertProduct;
        if (cv.source == ResourceType.any || (inputPool.count(cv.source) > 0 || outputPool.count(cv.source) > 0)) {
          // we have a matching resource, so use it
          for (var destRt in ResourceType.values) {
            if (destRt == cv.source || destRt == ResourceType.any || destRt == ResourceType.none) continue;
            for (var srcRt in ResourceType.values) {
              // we will try using every type as the "from". So for non any to any converters,
              // we will skip anything but the rt that matches what the converter source is
              if (srcRt == ResourceType.any ||
                  srcRt == ResourceType.none ||
                  srcRt == destRt ||
                  (cv.source != ResourceType.any && srcRt != cv.source)) continue;

              // this can happen for cv.source == ResourceType.any
              if (inputPool.count(srcRt) == 0 && outputPool.count(srcRt) == 0) continue;

              var ip2 = ResourcePool.of(inputPool);
              var op2 = ResourcePool.of(outputPool);
              if (ip2.count(srcRt) > 0) {
                ip2.sub1(srcRt);
              } else {
                op2.sub1(srcRt);
              }
              op2.add1(destRt);
              var conv2 = List<ConverterBaseProduct>.of(conv);
              conv2.remove(c);
              if (max.count(destRt) < op2.count(destRt) + ip2.count(destRt)) {
                max.set(destRt, op2.count(destRt) + ip2.count(destRt));
              }
              _findMaxResources(max, conv2, ip2, op2);
            }
          }
        }
      } else if (c.productType == ProductType.doubleResource) {
        var cv = c as DoubleResourceProduct;
        if (inputPool.count(cv.resourceType) > 0 || outputPool.count(cv.resourceType) > 0) {
          var ip2 = ResourcePool.of(inputPool);
          var op2 = ResourcePool.of(outputPool);
          if (op2.count(cv.resourceType) > 0) {
            op2.add1(cv.resourceType);
          } else if (ip2.count(cv.resourceType) > 0) {
            ip2.sub1(cv.resourceType);
            op2.add1(cv.resourceType);
            op2.add1(cv.resourceType);
          }
          var conv2 = List<ConverterBaseProduct>.of(conv);
          conv2.remove(c);

          if (max.count(cv.resourceType) < op2.count(cv.resourceType) + ip2.count(cv.resourceType)) {
            max.set(cv.resourceType, op2.count(cv.resourceType) + ip2.count(cv.resourceType));
          }

          var total = op2.getResourceCount() + ip2.getResourceCount();
          if (max.count(ResourceType.any) < total) {
            max.set(ResourceType.any, total);
          }
          _findMaxResources(max, conv2, ip2, op2);
        }
      } else {
        throw InvalidOperationError("found non converter type when counting resources");
      }
    }
  }
}
