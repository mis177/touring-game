class DatabaseNote {
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
}
