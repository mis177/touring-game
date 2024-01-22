List searchWithText(List list, String text) {
  return list.where((element) {
    return element.name.toLowerCase().contains(text.toLowerCase());
  }).toList();
}

List searchWithActivityFinished({
  required List list,
  required bool finished,
  required bool value,
}) {
  return list.where((element) {
    if (finished == true) {
      return element.isDone == value;
    } else {
      return element.isDone == !value;
    }
  }).toList();
}
