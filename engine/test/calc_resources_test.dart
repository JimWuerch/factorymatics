import 'package:engine/engine.dart';
import 'package:test/test.dart';

class TestProducts {
  final ConvertProduct clubConverter = ConvertProduct(ResourceType.club, ResourceType.any);
  final ConvertProduct spadeConverter = ConvertProduct(ResourceType.spade, ResourceType.any);
  final ConvertProduct heartConverter = ConvertProduct(ResourceType.heart, ResourceType.any);
  final ConvertProduct diamondConverter = ConvertProduct(ResourceType.diamond, ResourceType.any);
  final DoubleResourceProduct clubDoubler = DoubleResourceProduct(ResourceType.club);
  final DoubleResourceProduct spadeDoubler = DoubleResourceProduct(ResourceType.spade);
  final DoubleResourceProduct heartDoubler = DoubleResourceProduct(ResourceType.heart);
  final DoubleResourceProduct diamondDoubler = DoubleResourceProduct(ResourceType.diamond);
  final ConvertProduct anyConverter = ConvertProduct(ResourceType.any, ResourceType.any);
  final List<Part> _parts;

  TestProducts() : _parts = createParts() {
    clubConverter.part = _parts[0];
    spadeConverter.part = _parts[0];
    heartConverter.part = _parts[0];
    diamondConverter.part = _parts[0];
    clubDoubler.part = _parts[0];
    spadeDoubler.part = _parts[0];
    heartDoubler.part = _parts[0];
    diamondDoubler.part = _parts[0];
    anyConverter.part = _parts[0];
    clubConverter.prodIndex = 0;
    spadeConverter.prodIndex = 0;
    heartConverter.prodIndex = 0;
    diamondConverter.prodIndex = 0;
    clubDoubler.prodIndex = 0;
    spadeDoubler.prodIndex = 0;
    heartDoubler.prodIndex = 0;
    diamondDoubler.prodIndex = 0;
    anyConverter.prodIndex = 0;
  }
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

CalcResources cr = CalcResources();

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

      var paths = cr.getPayments(1, ResourceType.spade, pool, products);
      expect(paths.length, 1);
      expect(paths[0].getCost().count(ResourceType.club), 1);
      //dumpPaths(paths);
      paths = cr.getPayments(2, ResourceType.diamond, pool, products);
      expect(paths.length, 1);
      expect(paths[0].length, 2);
      expect(paths[0].getCost().count(ResourceType.club), 1);
      //dumpPaths(paths);

      pool.add1(ResourceType.diamond);
      products.add(tp.heartDoubler);
      paths = cr.getPayments(2, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 3);

      paths = cr.getPayments(1, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 2);

      products.add(tp.clubConverter);
      pool.add1(ResourceType.club);
      paths = cr.getPayments(2, ResourceType.diamond, pool, products);
      expect(paths.length, 4);
      //dumpPaths(paths);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      var products2 = <ConverterBaseProduct>[];
      products2.add(tp.spadeDoubler);
      products2.add(tp.heartConverter);
      products2.add(tp.spadeConverter);
      products2.add(tp.spadeConverter);
      var paths2 = cr.getPayments(2, ResourceType.diamond, pool2, products2);
      expect(paths2.length, 1);
      expect(paths2[0].length, 4);
      expect(paths2[0].getCost().count(ResourceType.heart), 1);
      //dumpPaths(paths2);
    });

    test('Test getPayments bug #1', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      products.add(tp.clubConverter);
      products.add(tp.spadeConverter);
      products.add(tp.diamondConverter);
      products.add(tp.clubDoubler);
      products.add(tp.diamondDoubler);
      var pool = ResourcePool();
      pool.add1(ResourceType.heart);
      pool.add1(ResourceType.heart);
      pool.add1(ResourceType.heart);
      pool.add1(ResourceType.spade);
      pool.add1(ResourceType.spade);

      var paths = cr.getPayments(7, ResourceType.any, pool, products);
      expect(paths.length, 3);
      //dumpPaths(paths);

      products = <ConverterBaseProduct>[];
      pool = ResourcePool();
      products.add(tp.heartConverter);
      products.add(tp.clubDoubler);
      products.add(tp.heartDoubler);
      pool.add1(ResourceType.heart);
      pool.add1(ResourceType.spade);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      var paths2 = cr.getPayments(7, ResourceType.any, pool, products);
      //dumpPaths(paths2);
      expect(paths2.length, 1);

      products = <ConverterBaseProduct>[];
      pool = ResourcePool();
      products.add(tp.heartDoubler);
      products.add(tp.diamondDoubler);
      products.add(tp.diamondConverter);
      products.add(tp.diamondConverter);
      products.add(tp.diamondConverter);
      pool.add1(ResourceType.spade);
      pool.add1(ResourceType.spade);
      pool.add1(ResourceType.spade);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);
      var paths3 = cr.getPayments(7, ResourceType.any, pool, products);
      //dumpPaths(paths3);
      expect(paths3.length, 2);
    });

    test('Test getPayments dedup', () {
      //var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      // products.add(tp.clubConverter);
      // products.add(tp.clubConverter);
      var pool = ResourcePool();

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);

      var paths = cr.getPayments(2, ResourceType.diamond, pool, products);
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

      var paths = cr.getPayments(2, ResourceType.any, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 3);

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);
      pool.add1(ResourceType.spade);
      paths = cr.getPayments(2, ResourceType.any, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 6);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      pool2.add1(ResourceType.diamond);
      products.add(tp.spadeDoubler);
      products.add(tp.heartConverter);
      paths = cr.getPayments(2, ResourceType.any, pool2, products);
      //dumpPaths(paths);
      expect(paths.length, 2);

      products.add(tp.clubDoubler);
      pool2.add1(ResourceType.spade);
      products.add(tp.heartDoubler);
      paths = cr.getPayments(2, ResourceType.any, pool2, products);
      //dumpPaths(paths);
      expect(paths.length, 7);
    });

    test('test any to any converter', () {
      var tp = TestProducts();
      var products = <ConverterBaseProduct>[];
      var pool = ResourcePool();

      pool.add1(ResourceType.diamond);
      pool.add1(ResourceType.club);
      pool.add1(ResourceType.spade);

      products.add(tp.anyConverter);
      var paths = cr.getPayments(2, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 2);

      products.add(tp.clubConverter);
      paths = cr.getPayments(2, ResourceType.diamond, pool, products);
      //dumpPaths(paths);
      expect(paths.length, 4);
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

      var max = cr.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 1, 1, 2, 1, 2);

      pool.add1(ResourceType.diamond);
      products.add(tp.heartDoubler);
      max = cr.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 2, 1, 3, 1, 4);

      products.add(tp.clubConverter);
      pool.add1(ResourceType.club);
      max = cr.getMaxResources(pool, products);
      //print(max);
      checkPool(max, 3, 2, 4, 2, 5);

      var pool2 = ResourcePool();
      pool2.add1(ResourceType.heart);
      var products2 = <ConverterBaseProduct>[];
      products2.add(tp.spadeDoubler);
      products2.add(tp.heartConverter);
      products2.add(tp.spadeConverter);
      products2.add(tp.spadeConverter);
      max = cr.getMaxResources(pool2, products2);
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

      max = cr.getMaxResources(pool3, products3);
      //print(max);
      checkPool(max, 2, 3, 2, 2, 6);
    });
  });
}
