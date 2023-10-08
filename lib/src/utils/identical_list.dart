extension IdenticalList on Iterable {
  bool hasSameElementsAs(Iterable list) {
    return every((e) => list.contains(e)) && length == list.length;
  }
}
