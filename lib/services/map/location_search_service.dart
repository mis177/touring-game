import 'dart:convert';
import 'package:touring_game/models/address.dart';
import 'package:http/http.dart' as http;

class LocationSearchApiService {
  Future<List<AddressModel>> fetchAddress(searchedText) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$searchedText&addressdetails=1&format=jsonv2'));

    if (response.statusCode == 200) {
      var adressMap =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      List<AddressModel> addresses = [];
      for (var entry in adressMap) {
        addresses.add(AddressModel.fromJson(entry));
      }
      return addresses;
    } else {
      throw Exception('Failed to load address');
    }
  }
}
