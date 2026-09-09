import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

abstract interface class UserDataService {
  Future<void> deleteUserData(String userId);
}

class FirebaseUserDataService implements UserDataService {
  FirebaseUserDataService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      final user = _firestore.collection('users').doc(userId);
      await _deleteCollection(user.collection('activities_done'));
      await _deleteCollection(user.collection('activities_notes'));
      await user.delete();
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    await Future.wait(
      snapshot.docs.map((document) => document.reference.delete()),
    );
  }
}
