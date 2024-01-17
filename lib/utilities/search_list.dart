List searchList(List list, String text) {
  return list.where((element) {
    return element.name.toLowerCase().contains(text.toLowerCase());
  }).toList();
}
