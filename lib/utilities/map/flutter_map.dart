import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touring_game/models/marker.dart';

import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:url_launcher/url_launcher.dart';

FlutterMap loadMap(
    {required MapController mapController,
    required Position? currentLocation,
    required CurrentLocationLayer locationLayer,
    required List<MyMarker> mapMarkers,
    required Widget Function(BuildContext, Widget, TileImage)? darkMode}) {
  return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: lat_lng.LatLng(
            currentLocation == null ? 50.5381 : currentLocation.latitude,
            currentLocation == null ? 22.7252 : currentLocation.longitude),
        initialZoom: 18,
        maxZoom: 20,
        minZoom: 4,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileBuilder: darkMode, //darkModeTileBuilder,
          maxNativeZoom: 20,
          minNativeZoom: 4,
        ),
        RichAttributionWidget(
          animationConfig: const ScaleRAWA(),
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
        MarkerLayer(markers: mapMarkers),
        locationLayer,
      ]);
}
