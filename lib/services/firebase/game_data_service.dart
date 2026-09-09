import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

class GameServicePlace {
  const GameServicePlace({required this.id, required this.name});

  final String id;
  final String name;
}

class GameServiceActivity {
  const GameServiceActivity({
    required this.id,
    required this.placeId,
    required this.name,
    required this.webUrl,
    required this.latitude,
    required this.longitude,
    required this.isDone,
  });

  final String id;
  final String placeId;
  final String name;
  final String webUrl;
  final double latitude;
  final double longitude;
  final bool isDone;
}

class GameServiceNote {
  const GameServiceNote({
    required this.id,
    required this.activityId,
    required this.content,
    required this.color,
    required this.positionX,
    required this.positionY,
    required this.isImage,
  });

  final String id;
  final String activityId;
  final String content;
  final String color;
  final double positionX;
  final double positionY;
  final bool isImage;
}

abstract interface class GameDataService {
  Future<List<GameServicePlace>> loadPlaces();
  Future<List<GameServiceActivity>> loadActivities({
    required String placeId,
    required String userId,
  });
  Future<void> updateActivityDone({
    required String userId,
    required String activityId,
    required bool isDone,
  });
  Future<void> saveNote({
    required String userId,
    required GameServiceNote note,
  });
  Future<List<GameServiceNote>> loadNotes({
    required String userId,
    required String activityId,
  });
  Future<void> deleteNote({required String userId, required String noteId});
}

class FirebaseGameDataService implements GameDataService {
  FirebaseGameDataService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  @override
  Future<List<GameServicePlace>> loadPlaces() async {
    return _guard(() async {
      final snapshot = await _firestore.collection('places').get();
      return snapshot.docs
          .map(
            (document) => GameServicePlace(
              id: document.id,
              name: document.data()['name'] as String,
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<List<GameServiceActivity>> loadActivities({
    required String placeId,
    required String userId,
  }) async {
    return _guard(() async {
      final activities = await _firestore
          .collection('places')
          .doc(placeId)
          .collection('activities')
          .get();
      return Future.wait(
        activities.docs.map((activity) async {
          final completion = await _firestore
              .collection('users')
              .doc(userId)
              .collection('activities_done')
              .doc(activity.id)
              .get();
          final data = activity.data();
          final point = data['coords'] as GeoPoint;
          return GameServiceActivity(
            id: activity.id,
            placeId: placeId,
            name: data['name'] as String,
            webUrl: data['webUrl'] as String,
            latitude: point.latitude,
            longitude: point.longitude,
            isDone: completion.data()?['done'] as bool? ?? false,
          );
        }),
      );
    });
  }

  @override
  Future<void> updateActivityDone({
    required String userId,
    required String activityId,
    required bool isDone,
  }) {
    return _guard(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('activities_done')
          .doc(activityId)
          .set({'done': isDone}),
    );
  }

  @override
  Future<void> saveNote({
    required String userId,
    required GameServiceNote note,
  }) {
    return _guard(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('activities_notes')
          .doc(note.id)
          .set({
            'activity_id': note.activityId,
            'color': note.color,
            'id': note.id,
            'content': note.content,
            'position_x': note.positionX,
            'position_y': note.positionY,
            'is_image': note.isImage,
          }),
    );
  }

  @override
  Future<List<GameServiceNote>> loadNotes({
    required String userId,
    required String activityId,
  }) async {
    return _guard(() async {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities_notes')
          .where('activity_id', isEqualTo: activityId)
          .get();
      return snapshot.docs
          .map((document) {
            final data = document.data();
            return GameServiceNote(
              id: data['id'] as String,
              activityId: activityId,
              content: data['content'] as String,
              color: data['color'] as String,
              positionX: double.parse(data['position_x'].toString()),
              positionY: double.parse(data['position_y'].toString()),
              isImage: data['is_image'] as bool,
            );
          })
          .toList(growable: false);
    });
  }

  @override
  Future<void> deleteNote({required String userId, required String noteId}) {
    return _guard(
      () => _firestore
          .collection('users')
          .doc(userId)
          .collection('activities_notes')
          .doc(noteId)
          .delete(),
    );
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }
}
