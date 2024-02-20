import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class DatabaseActivity extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String title;
  final String description;
  final GeoPoint coords;
  bool isDone = false;
  final String placeId;

  DatabaseActivity(
      {required this.id,
      required this.name,
      required this.imagePath,
      required this.isDone,
      required this.title,
      required this.description,
      required this.coords,
      required this.placeId});

  factory DatabaseActivity.fromJson(
      Map<String, dynamic> jsonData, placeId, activityId, isDone) {
    return DatabaseActivity(
      name: jsonData['name'],
      id: activityId,
      imagePath: jsonData['image_path'] ?? '',
      isDone: isDone,
      title: jsonData['title'] ?? '',
      description: jsonData['description'] ?? '',
      coords: jsonData['coords'],
      placeId: placeId,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, imagePath, isDone, title, description, coords, placeId];
}
