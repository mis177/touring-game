import 'package:touring_game/models/address.dart';
import 'package:touring_game/services/map/location_search_service.dart';

class LocationSearchRepository {
  LocationSearchApiService? service;
  LocationSearchRepository() {
    service = LocationSearchApiService();
  }
  Future<List<AddressModel>> fetchAddress(String searchedText) async =>
      await service!.fetchAddress(searchedText);
}
