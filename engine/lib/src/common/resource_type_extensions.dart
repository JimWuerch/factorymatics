import 'package:engine/engine.dart';

String resourceListToString(List<ResourceType>? src) {
  if (src == null) return '';

  var chars = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  var s = StringBuffer();
  for (var resource in src) {
    s.write(chars[ResourceType.values.indexOf(resource)]);
  }
  return s.toString();
}

List<ResourceType> stringToResourceList(String? src) {
  var ret = <ResourceType>[];
  if (src != null) {
    var a = 'A'.codeUnitAt(0);
    for (var i = 0; i < src.length; ++i) {
      ret.add(ResourceType.values[src.codeUnitAt(i) - a]);
    }
  }
  return ret;
}

String resourceMapToString(Map<ResourceType, int> resources) {
  var chars = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  var ret = StringBuffer();
  resources.forEach((key, value) {
    if (value != null && key != ResourceType.any && key != ResourceType.none) {
      for (var i = 0; i < value; i++) {
        ret.write(chars[ResourceType.values.indexOf(key)]);
      }
    }
  });
  return ret.toString();
}

Map<ResourceType, int> stringToResourceMap(String? src) {
  var ret = <ResourceType, int>{};
  ret[ResourceType.club] = 0;
  ret[ResourceType.diamond] = 0;
  ret[ResourceType.heart] = 0;
  ret[ResourceType.spade] = 0;

  if (src != null) {
    var a = 'A'.codeUnitAt(0);
    for (var i = 0; i < src.length; ++i) {
      var resource = ResourceType.values[src.codeUnitAt(i) - a];
      if (resource != ResourceType.any && resource != ResourceType.none) {
        ret[resource] = ret[resource]! + 1;
      }
    }
  }
  return ret;
}

String resourceMapStateToString(Map<ResourceType, GameStateVar<int>> resources) {
  var chars = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  var ret = StringBuffer();
  resources.forEach((key, value) {
    if (value != null && key != ResourceType.any && key != ResourceType.none) {
      for (var i = 0; i < value.value!; i++) {
        ret.write(chars[ResourceType.values.indexOf(key)]);
      }
    }
  });
  return ret.toString();
}
