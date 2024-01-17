import 'package:latlong2/latlong.dart' as lat_lng;

class AddressModel {
  final String name;
  final lat_lng.LatLng coords;

  AddressModel({required this.name, required this.coords});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'display_name': String name,
        'lat': String lat,
        'lon': String lon,
      } =>
        AddressModel(
          name: name,
          coords: lat_lng.LatLng(double.parse(lat), double.parse(lon)),
        ),
      _ => throw const FormatException('Failed to load address.'),
    };
  }
}
