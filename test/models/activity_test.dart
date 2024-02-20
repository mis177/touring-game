import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';

void main() {
  Map<String, dynamic> jsonData = {
    'name': "Test Activity",
    'image_path': 'path/to/image',
    'title': 'Test title',
    'description': 'Activity for testing',
    'coords': const GeoPoint(10, 20),
  };

  DatabaseActivity correctDatabaseActivityResult = DatabaseActivity(
    id: '1',
    name: 'Test Activity',
    imagePath: 'path/to/image',
    isDone: true,
    title: 'Test title',
    description: 'Activity for testing',
    coords: const GeoPoint(10, 20),
    placeId: '2',
  );

  group('Test initializing DatabaseActivity from Json', () {
    test('Test DatabaseActivity from jsonData function', () {
      expect(DatabaseActivity.fromJson(jsonData, '2', '1', true),
          correctDatabaseActivityResult);
    });
  });
}
