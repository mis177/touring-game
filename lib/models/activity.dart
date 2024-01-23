import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseActivity {
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
}
