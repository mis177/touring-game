import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:touring_game/models/activity.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:touring_game/utilities/routes.dart';

List<Marker> getMarkers(
    {required List<DatabaseActivity> activities,
    required BuildContext context,
    required Function() reloadMarkers}) {
  List<Marker> markers = [];
  for (var activity in activities) {
    Icon activityIcon;
    if (activity.isDone) {
      activityIcon = const Icon(
        Icons.location_on_sharp,
        size: 40,
      );
    } else {
      activityIcon = const Icon(
        Icons.location_on_outlined,
        size: 40,
      );
    }

    markers.add(Marker(
      point:
          lat_lng.LatLng(activity.coords.latitude, activity.coords.longitude),
      child: IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return PopScope(
                  child: Dialog(
                      child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          activity.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Text(activity.title),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                openActivitityDetails,
                                arguments: [activity, reloadMarkers]);
                          },
                          child: const Text('Open details'),
                        )
                      ],
                    ),
                  )),
                );
              });
        },
        icon: activityIcon,
      ),
    ));
  }

  return markers;
}
