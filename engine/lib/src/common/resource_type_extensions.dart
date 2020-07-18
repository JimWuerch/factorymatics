import 'package:engine/engine.dart';

String resourceListToString(List<ResourceType> src) {
  if (src == null) return '';

  var chars = <String>['N', 'H', 'S', 'D', 'C', 'A', 'X', 'Y', 'Z'];
  var s = StringBuffer();
  for (var resource in src) {
    s.write(chars[ResourceType.values.indexOf(resource)]);
  }
  return s.toString();
}

List<ResourceType> stringToResourceList(String src) {
  var ret = <ResourceType>[];
  if (src != null) {
    var a = 'A'.codeUnitAt(0);
    for (var i = 0; i < src.length; ++i) {
      ret.add(ResourceType.values[a - src.codeUnitAt(i)]);
    }
  }
  return ret;
}
