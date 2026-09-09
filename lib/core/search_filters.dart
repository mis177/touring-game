import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/named_entity.dart';

enum ActivityStatusFilter { finished, unfinished }

List<T> searchWithText<T extends NamedEntity>(List<T> list, String text) {
  return list.where((element) {
    return element.name.toLowerCase().contains(text.toLowerCase());
  }).toList();
}

List<DatabaseActivity> searchWithActivityFinished({
  required List<DatabaseActivity> list,
  required bool finished,
}) {
  return list.where((activity) => activity.isDone == finished).toList();
}
