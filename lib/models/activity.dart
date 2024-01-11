class DatabaseActivity {
  final String id;
  final String name;
  final String imagePath;
  final String title;
  final String description;
  bool isDone = false;

  DatabaseActivity(
      {required this.id,
      required this.name,
      required this.imagePath,
      required this.isDone,
      required this.title,
      required this.description});
}
