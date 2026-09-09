import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/note.dart';

void main() {
  Map<String, dynamic> jsonData = {
    'id': "33",
    'color': '4292933626',
    'content': 'Test text content',
    'position_x': 100,
    'position_y': 300,
    'is_image': false,
  };

  const correctDatabaseNoteResult = DatabaseNote(
    id: '33',
    activityId: '45',
    content: 'Test text content',
    color: '4292933626',
    positionX: 100,
    positionY: 300,
    isImage: false,
    imagePath: null,
  );

  group('Test initializing DatabaseNote from Json', () {
    test('Test DatabaseNote from jsonData function', () {
      expect(DatabaseNote.fromJson(jsonData, '45'), correctDatabaseNoteResult);
    });
  });
}
