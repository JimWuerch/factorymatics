import 'dart:math';

import 'package:engine/engine.dart';
import 'package:test/test.dart';

class TestProducts {
  final ConvertProduct clubConverter = ConvertProduct(null, ResourceType.club, ResourceType.any);
  final ConvertProduct spadeConverter = ConvertProduct(null, ResourceType.spade, ResourceType.any);
  final ConvertProduct heartConverter = ConvertProduct(null, ResourceType.heart, ResourceType.any);
  final ConvertProduct diamondConverter = ConvertProduct(null, ResourceType.diamond, ResourceType.any);
  final DoubleResourceProduct clubDoubler = DoubleResourceProduct(null, ResourceType.club);
  final DoubleResourceProduct spadeDoubler = DoubleResourceProduct(null, ResourceType.spade);
  final DoubleResourceProduct heartDoubler = DoubleResourceProduct(null, ResourceType.heart);
  final DoubleResourceProduct diamondDoubler = DoubleResourceProduct(null, ResourceType.diamond);
}

void dumpPaths(List<SpendHistory> paths) {
  print('There are ${paths.length} paths:');
  for (var path in paths) {
    path.dump();
    print('-----');
  }
  print('*****');
}

void checkPool(ResourcePool pool, int heart, int spade, int diamond, int club, int any) {
  expect(pool.count(ResourceType.heart), heart);
  expect(pool.count(ResourceType.club), club);
  expect(pool.count(ResourceType.diamond), diamond);
  expect(pool.count(ResourceType.spade), spade);
  expect(pool.count(ResourceType.any), any);
}

void main() {
  group('calc_data find needed resource tests', () {
    setUp(() {});

    test('Test getPayments for non-any resources', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      products.add(tp.clubConverter);
      products.add(tp.diamondDoubler);
      var pool = ResourcePool();
      pool.add1(ResourceType.club);

      var paths = CalcResources.getPayments(1, ResourceType.spade, pool, products);
      expect(paths.length, 1);
      expect(paths[0].getCost().count(ResourceType.club), 1);
      //dumpPaths(paths);
      paths = CalcResources.getPayments(2, ResourceType.diamond, pool, products);
      expect(paths.length, 1);
      expect(paths[0].length, 2);
      expect(paths[0].getCost().count(ResourceType.club), 1);
      //dumpPaths(paths);

      pool.add1(ResourceType.diamond);
      products.add(tp.heartDoubler);
      paths = CalcResources.getPayments(2, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 3);

      paths = CalcResources.getPayments(1, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 2);

      products.add(tp.clubConverter);
      pool.add1(ResourceType.club);
      paths = CalcResources.getPayments(2, ResourceType.diamond, pool, products);
      expect(paths.length, 4);
      //dumpPaths(paths);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      var products2 = <ConverterBaseProduct>[];
      products2.add(tp.spadeDoubler);
      products2.add(tp.heartConverter);
      products2.add(tp.spadeConverter);
      products2.add(tp.spadeConverter);
      var paths2 = CalcResources.getPayments(2, ResourceType.diamond, pool2, products2);
      expect(paths2.length, 1);
      expect(paths2[0].length, 4);
      expect(paths2[0].getCost().count(ResourceType.heart), 1);
      //dumpPaths(paths2);
    });

    test('Test getPayments dedup', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      // products.add(tp.clubConverter);
      // products.add(tp.clubConverter);
      var pool = ResourcePool();

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);

      var paths = CalcResources.getPayments(2, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 1);
      expect(paths[0].length, 2);
      expect(paths[0].getCost().count(ResourceType.diamond), 2);
    });

    test('Test getPayments any', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      var pool = ResourcePool();

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);
      pool.add1(ResourceType.spade);

      var paths = CalcResources.getPayments(2, ResourceType.any, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 3);

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);
      pool.add1(ResourceType.spade);
      paths = CalcResources.getPayments(2, ResourceType.any, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 6);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      pool2.add1(ResourceType.diamond);
      products.add(tp.spadeDoubler);
      products.add(tp.heartConverter);
      paths = CalcResources.getPayments(2, ResourceType.any, pool2, products);
      //dumpPaths(paths);
      expect(paths.length, 2);

      products.add(tp.clubDoubler);
      pool2.add1(ResourceType.spade);
      products.add(tp.heartDoubler);
      paths = CalcResources.getPayments(2, ResourceType.any, pool2, products);
      //dumpPaths(paths);
      expect(paths.length, 7);
    });
  });

  group('calc_data get max resources tests', () {
    setUp(() {});

    test('Test getmax for non-any resources', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      products.add(tp.clubConverter);
      products.add(tp.diamondDoubler);
      var pool = ResourcePool();
      pool.add1(ResourceType.club);

      var max = CalcResources.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 1, 1, 2, 1, 2);

      pool.add1(ResourceType.diamond);
      products.add(tp.heartDoubler);
      max = CalcResources.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 2, 1, 3, 1, 4);

      products.add(tp.clubConverter);
      pool.add1(ResourceType.club);
      max = CalcResources.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 3, 2, 4, 2, 5);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      var products2 = <ConverterBaseProduct>[];
      products2.add(tp.spadeDoubler);
      products2.add(tp.heartConverter);
      products2.add(tp.spadeConverter);
      products2.add(tp.spadeConverter);
      max = CalcResources.getMaxResources(pool2, products2);
      //print(max);
      checkPool(max, 2, 2, 2, 2, 2);

      var pool3 = ResourcePool();
      var products3 = <ConverterBaseProduct>[];
      products3.add(tp.spadeDoubler);
      products3.add(tp.heartConverter);
      products3.add(tp.clubDoubler);
      products3.add(tp.heartDoubler);
      pool3.add1(ResourceType.spade);
      pool3.add1(ResourceType.heart);
      pool3.add1(ResourceType.diamond);

      max = CalcResources.getMaxResources(pool3, products3);
      //print(max);
      checkPool(max, 2, 3, 2, 2, 6);
    });
  });
}