import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/utilities/map/flutter_map.dart';

void main() {
  test('identifies tile requests to OpenStreetMap', () {
    final map = loadMap(
      mapController: MapController(),
      currentLocation: null,
      locationLayer: CurrentLocationLayer(),
      mapMarkers: const [],
      darkMode: null,
    );

    final tileLayer = map.children.whereType<TileLayer>().single;

    expect(
      tileLayer.tileProvider.headers['User-Agent'],
      'flutter_map (io.github.mis177.touring_game)',
    );
    expect(tileLayer.maxNativeZoom, 19);
  });
}
