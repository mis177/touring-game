import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

class AddressModel extends Equatable {
  final String name;
  final lat_lng.LatLng coords;

  const AddressModel({required this.name, required this.coords});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['display_name'],
      coords:
          lat_lng.LatLng(double.parse(json['lat']), double.parse(json['lon'])),
    );
  }

  @override
  List<Object?> get props => [name, coords.latitude, coords.longitude];
}
