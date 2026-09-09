import 'package:equatable/equatable.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/named_entity.dart';

class DatabaseActivity extends Equatable implements NamedEntity {
  final String id;
  @override
  final String name;
  final String webUrl;
  final Coordinates coords;
  final bool isDone;
  final String placeId;

  const DatabaseActivity({
    required this.id,
    required this.name,
    required this.webUrl,
    required this.isDone,
    required this.coords,
    required this.placeId,
  });

  factory DatabaseActivity.fromJson(
    Map<String, dynamic> jsonData,
    String placeId,
    String activityId,
    bool isDone,
    Coordinates coordinates,
  ) {
    return DatabaseActivity(
      name: jsonData['name'],
      id: activityId,
      isDone: isDone,
      webUrl: jsonData['webUrl'],
      coords: coordinates,
      placeId: placeId,
    );
  }

  DatabaseActivity copyWith({bool? isDone}) => DatabaseActivity(
    id: id,
    name: name,
    webUrl: webUrl,
    isDone: isDone ?? this.isDone,
    coords: coords,
    placeId: placeId,
  );

  @override
  List<Object?> get props => [id, name, webUrl, isDone, coords, placeId];
}
