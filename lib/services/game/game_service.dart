import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_provider.dart';

class FirebaseCloudGameService {
  final FirebaseCloudGameProvider provider;
  FirebaseCloudGameService({required this.provider});
  List<DatabasePlace> places = [];

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

  List searchList(List list, String text) {
    return list.where((element) {
      return element.name.toLowerCase().contains(text.toLowerCase());
    }).toList();
  }

  Future<void> loadMap(MapController controller) async {
    await controller.currentLocation();
  }
}
