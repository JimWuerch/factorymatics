// Helpers for json serialization
List<T> listFromJson<T>(dynamic json) {
  var list = json as List<dynamic>;
  return list.map<T>((dynamic e) => e as T).toList();
}

Map<String, V> mapFromJson<String, V>(dynamic json) {
  var data = json as Map<String, dynamic>;
  var ret = <String, V>{};
  for (var item in data.entries) {
    ret[item.key] = item.value as V;
  }
  return ret;
}
