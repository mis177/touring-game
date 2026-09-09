import 'package:equatable/equatable.dart';
import 'package:touring_game/models/named_entity.dart';

class DatabasePlace extends Equatable implements NamedEntity {
  final String id;
  @override
  final String name;

  const DatabasePlace({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
