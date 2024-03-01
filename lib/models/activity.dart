import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class DatabaseActivity extends Equatable {
  final String id;
  final String name;
  final String webUrl;
  final GeoPoint coords;
  bool isDone = false;
  final String placeId;

  DatabaseActivity(
      {required this.id,
      required this.name,
      required this.webUrl,
      required this.isDone,
      required this.coords,
      required this.placeId});

  factory DatabaseActivity.fromJson(
      Map<String, dynamic> jsonData, placeId, activityId, isDone) {
    return DatabaseActivity(
      name: jsonData['name'],
      id: activityId,
      isDone: isDone,
      webUrl: jsonData['webUrl'],
      coords: jsonData['coords'],
      placeId: placeId,
    );
  }

  @override
  List<Object?> get props => [id, name, isDone, coords, placeId];
}
