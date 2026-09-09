import 'package:equatable/equatable.dart';

class DatabaseNote extends Equatable {
  final String id;
  final String activityId;
  final String content;
  final bool isImage;
  final String? imagePath;
  final String? imageUrl;
  final String color;
  final double positionX;
  final double positionY;

  const DatabaseNote({
    required this.id,
    required this.activityId,
    required this.content,
    required this.color,
    required this.positionX,
    required this.positionY,
    required this.isImage,
    required this.imagePath,
    this.imageUrl,
  });

  factory DatabaseNote.fromJson(
    Map<String, dynamic> jsonData,
    String activityId, {
    String? imageUrl,
  }) {
    final isImage = jsonData['is_image'] as bool;
    final storedContent = jsonData['content'] as String;
    return DatabaseNote(
      id: jsonData['id'] as String,
      activityId: activityId,
      content: isImage ? '' : storedContent,
      color: jsonData['color'] as String,
      positionX: double.parse(jsonData['position_x'].toString()),
      positionY: double.parse(jsonData['position_y'].toString()),
      isImage: isImage,
      imagePath: isImage ? storedContent : null,
      imageUrl: imageUrl,
    );
  }

  DatabaseNote copyWith({
    String? content,
    String? imagePath,
    String? imageUrl,
    String? color,
    double? positionX,
    double? positionY,
  }) => DatabaseNote(
    id: id,
    activityId: activityId,
    content: content ?? this.content,
    color: color ?? this.color,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    isImage: isImage,
    imagePath: imagePath ?? this.imagePath,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  @override
  List<Object?> get props => [
    id,
    activityId,
    content,
    isImage,
    imagePath,
    imageUrl,
    color,
    positionX,
    positionY,
  ];
}
