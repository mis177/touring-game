import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository();

  @override
  Future<Coordinates> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permission is permanently denied. Enable it in settings.',
        );
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permission was denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationException {
      rethrow;
    } on Exception catch (error) {
      throw LocationException('Could not determine your location.', error);
    }
  }
}
