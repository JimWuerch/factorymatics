// Helpers for json serialization
List<T> listFromJson<T>(dynamic json) {
   var list = json as List<dynamic>;
    return list.map<T>((dynamic e) => e as T).toList();
}