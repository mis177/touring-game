import 'package:flutter_map/flutter_map.dart';

class MyMarker extends Marker {
  final bool done;
  const MyMarker(
      {required super.point, required super.child, required this.done});
}
