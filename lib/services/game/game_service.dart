import 'package:flutter/material.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_provider.dart';

class FirebaseCloudGameService {
  late FirebaseCloudGameProvider provider;
  List<DatabasePlace> places = [];
  List<DatabaseActivity> allActivities = [];
  List<DatabaseNote> activityNotes = [];

  static final FirebaseCloudGameService _shared =
      FirebaseCloudGameService._sharedInstance();
  FirebaseCloudGameService._sharedInstance();
  factory FirebaseCloudGameService(
      {required FirebaseCloudGameProvider provider}) {
    _shared.provider = provider;
    return _shared;
  }

  Future<List<DatabasePlace>> allPlaces() async {
    List<DatabasePlace> placesList = [];
    await provider.allPlaces().then((value) async {
      for (var doc in value.docs) {
        placesList.add(DatabasePlace(
          name: doc.data()['name'],
          id: doc.id,
        ));
        allActivities += await provider.getPlaceActivities(placeId: doc.id);
      }
    });
    places = placesList;
    return placesList;
  }

  List<DatabaseActivity> getPlaceActivities({required String placeId}) {
    return allActivities
        .where((element) => element.placeId == placeId)
        .toList();
  }

  Future<Image> getImage({required String path}) async {
    var image = Image.network(
      await provider.getImage(path: path),
      fit: BoxFit.scaleDown,
    );
    return image;
  }

  void activityDoneChanged(DatabaseActivity activity) {
    return provider.activityDoneChanged(activity);
  }

  Future<void> getActivityNotes({required String activityId}) async {
    activityNotes = await provider.getActivityNotes(activityId: activityId);
  }

  Future<void> addActivityNote({required DatabaseNote note}) async {
    await provider.addActivityNote(note: note);
    activityNotes[
        activityNotes.indexWhere((element) => element.id == note.id)] = note;
  }

  Future<void> deleteNote({required DatabaseNote note}) async {
    await provider.deleteNote(note: note);
    activityNotes.remove(note);
  }

  Future<void> deleteImageFromStorage({required String imagePath}) async {
    await provider.deleteImageFromStorage(imagePath: imagePath);
  }
}
