import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';

void main() {
  Map<String, dynamic> jsonData = {
    'name': "Test Activity",
    'image_path': 'path/to/image',
    'webUrl': 'path/to/web',
  };

  const correctDatabaseActivityResult = DatabaseActivity(
    id: '1',
    name: 'Test Activity',
    webUrl: 'path/to/web',
    isDone: true,
    coords: Coordinates(latitude: 10, longitude: 20),
    placeId: '2',
  );

  group('Test initializing DatabaseActivity from Json', () {
    test('Test DatabaseActivity from jsonData function', () {
      expect(
        DatabaseActivity.fromJson(
          jsonData,
          '2',
          '1',
          true,
          const Coordinates(latitude: 10, longitude: 20),
        ),
        correctDatabaseActivityResult,
      );
    });
  });
}
