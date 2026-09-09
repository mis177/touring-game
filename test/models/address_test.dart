import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';

void main() {
  Map<String, dynamic> jsonData = {
    'display_name': "Test address",
    'lat': '10',
    'lon': '20',
  };

  const correctAddressModelResult = AddressModel(
    name: 'Test address',
    coords: Coordinates(latitude: 10, longitude: 20),
  );

  group('Test initializing AddressModel from Json', () {
    test('Test AddressModel from jsonData function', () {
      expect(AddressModel.fromJson(jsonData), correctAddressModelResult);
    });
  });
}
