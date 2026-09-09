import 'package:touring_game/models/coordinates.dart';

abstract interface class LocationRepository {
  Future<Coordinates> getCurrentLocation();
}
