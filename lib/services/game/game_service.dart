import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_provider.dart';

class FirebaseCloudGameService {
  final FirebaseCloudGameProvider provider;
  FirebaseCloudGameService({required this.provider});
  List<DatabasePlace> places = [];
  List<DatabaseActivity> allActivities = [];
  List<Marker> allMarkers = [];

  Future<List<DatabasePlace>> allPlaces() async {
    List<DatabasePlace> placesList = [];
    await provider.allPlaces().then((value) {
      for (var doc in value.docs) {
        placesList.add(DatabasePlace(
          name: doc.data()['name'],
          id: doc.id,
        ));
      }
    });
    places = placesList;
    return placesList;
  }

  Future<List<DatabaseActivity>> getPlaceActivities(
      {required String placeId}) async {
    return await provider.getPlaceActivities(placeId: placeId);
  }

  Future<Image> getImage({required String path}) async {
    var test = Image.network(await provider.getImage(path: path));
    return test;
  }

  void activityDone(DatabaseActivity activity) {
    return provider.activityDone(activity);
  }

  Future<List<DatabaseActivity>> getAllActivities(
      List<DatabasePlace> places) async {
    List<DatabaseActivity> activities = [];
    for (var place in places) {
      activities += await getPlaceActivities(placeId: place.id);
    }
    allActivities = activities;
    return activities;
  }
}
