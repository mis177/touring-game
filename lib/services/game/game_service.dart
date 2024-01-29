import 'package:flutter/material.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_provider.dart';

class FirebaseCloudGameService {
  late FirebaseCloudGameProvider provider;
  List<DatabasePlace> places = [];
  List<DatabaseActivity> allActivities = [];

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
    var test = Image.network(
      await provider.getImage(path: path),
      fit: BoxFit.scaleDown,
    );
    return test;
  }

  void activityDoneChanged(DatabaseActivity activity) {
    return provider.activityDoneChanged(activity);
  }

  // Future<List<DatabaseActivity>> getAllActivities(
  //     List<DatabasePlace> places) async {
  //   List<DatabaseActivity> activities = [];
  //   for (var place in places) {
  //     activities += await getPlaceActivities(placeId: place.id);
  //   }
  //   allActivities = activities;

  //   return activities;
  // }
}
