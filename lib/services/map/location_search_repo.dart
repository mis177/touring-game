import 'package:http/http.dart' as http;
import 'package:touring_game/models/address.dart';
import 'package:touring_game/services/map/location_search_service.dart';
import 'package:touring_game/services/map/place_search_repository.dart';

class LocationSearchRepository implements PlaceSearchRepository {
  LocationSearchRepository({LocationSearchApiService? service})
    : _service = service ?? LocationSearchApiService(http.Client());

  final LocationSearchApiService _service;

  @override
  Future<List<AddressModel>> search(String query) =>
      _service.fetchAddress(query);

  @override
  void close() => _service.close();
}
