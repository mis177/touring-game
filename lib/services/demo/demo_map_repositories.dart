import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/place_search_repository.dart';

class DemoPlaceSearchRepository implements PlaceSearchRepository {
  static const _addresses = [
    AddressModel(
      name: 'Wawel Castle, Kraków',
      coords: Coordinates(latitude: 50.054, longitude: 19.936),
    ),
    AddressModel(
      name: 'Main Market Square, Kraków',
      coords: Coordinates(latitude: 50.0617, longitude: 19.9373),
    ),
    AddressModel(
      name: 'Warsaw Old Town',
      coords: Coordinates(latitude: 52.2497, longitude: 21.0122),
    ),
  ];

  @override
  Future<List<AddressModel>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    return List.unmodifiable(
      _addresses.where(
        (address) => address.name.toLowerCase().contains(normalized),
      ),
    );
  }

  @override
  void close() {}
}

class DemoLocationRepository implements LocationRepository {
  const DemoLocationRepository();

  @override
  Future<Coordinates> getCurrentLocation() async =>
      const Coordinates(latitude: 50.0617, longitude: 19.9373);
}
