import 'package:touring_game/models/address.dart';

abstract interface class PlaceSearchRepository {
  Future<List<AddressModel>> search(String query);
  void close();
}
