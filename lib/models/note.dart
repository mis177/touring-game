import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class DatabaseNote extends Equatable {
  final String id;
  final String activityId;
  dynamic content;
  final bool isImage;
  String? imagePath;
  String color;
  double positionX;
  double positionY;

  DatabaseNote({
    required this.id,
    required this.activityId,
    required this.content,
    required this.color,
    required this.positionX,
    required this.positionY,
    required this.isImage,
    required this.imagePath,
  });

  factory DatabaseNote.fromJson(
      Map<String, dynamic> jsonData, content, activityId) {
    return DatabaseNote(
        id: jsonData['id'],
        activityId: activityId,
        content: content,
        color: jsonData['color'],
        positionX: double.parse(jsonData['position_x'].toString()),
        positionY: double.parse(jsonData['position_y'].toString()),
        isImage: jsonData['is_image'],
        imagePath: jsonData['content']);
  }

  @override
  List<Object?> get props => [
        id,
        activityId,
        content.toString(),
        isImage,
        imagePath,
        color,
        positionX,
        positionY
      ];
}
