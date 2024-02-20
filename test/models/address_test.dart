import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/address.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

void main() {
  Map<String, dynamic> jsonData = {
    'display_name': "Test address",
    'lat': '10',
    'lon': '20',
  };

  AddressModel correctAddressModelResult =
      const AddressModel(name: 'Test address', coords: lat_lng.LatLng(10, 20));

  group('Test initializing AddressModel from Json', () {
    test('Test AddressModel from jsonData function', () {
      expect(AddressModel.fromJson(jsonData), correctAddressModelResult);
    });
  });
}
