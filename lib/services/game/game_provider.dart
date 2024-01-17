import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:touring_game/models/activity.dart';

class FirebaseCloudGameProvider {
  final placesList = FirebaseFirestore.instance.collection('places');
  final instance = FirebaseStorage.instance.ref();

  Future<String> getImage({required String path}) async {
    var imageRef = instance.child(path);

    return await imageRef.getDownloadURL();
  }

  static final FirebaseCloudGameProvider _shared =
      FirebaseCloudGameProvider._sharedInstance();
  FirebaseCloudGameProvider._sharedInstance();
  factory FirebaseCloudGameProvider() => _shared;

  Future<QuerySnapshot<Map<String, dynamic>>> allPlaces() async {
    return await FirebaseFirestore.instance.collection('places').get();
  }

  Future<List<DatabaseActivity>> getPlaceActivities(
      {required String placeId}) async {
    List<DatabaseActivity> activitiesList = [];
    bool isDone = false;
    await FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .collection('activities')
        .get()
        .then((activities) async {
      for (var activity in activities.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('activities_done')
            .doc(activity.id)
            .get()
            .then((value) => isDone = value.data()?['done'] ?? false);
        var databaseData = activity.data();

        activitiesList.add(DatabaseActivity(
            name: databaseData['name'],
            id: activity.id,
            imagePath: databaseData['image_path'] ?? '',
            isDone: isDone,
            title: databaseData['title'] ?? '',
            description: databaseData['description'] ?? '',
            coords: databaseData['coords']));
      }
    });

    return activitiesList;
  }

  void activityDoneChanged(DatabaseActivity activity) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('activities_done')
        .doc(activity.id)
        .set({'done': activity.isDone});
  }
}
