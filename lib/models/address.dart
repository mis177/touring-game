import 'package:equatable/equatable.dart';
import 'package:touring_game/models/coordinates.dart';

class AddressModel extends Equatable {
  final String name;
  final Coordinates coords;

  const AddressModel({required this.name, required this.coords});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['display_name'],
      coords: Coordinates(
        latitude: double.parse(json['lat']),
        longitude: double.parse(json['lon']),
      ),
    );
  }

  @override
  List<Object?> get props => [name, coords.latitude, coords.longitude];
}
