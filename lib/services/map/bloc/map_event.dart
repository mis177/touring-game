import 'package:equatable/equatable.dart';
import 'package:touring_game/core/search_filters.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapEventLoadMap extends MapEvent {
  const MapEventLoadMap();
}

class MapEventGetUserLocation extends MapEvent {
  const MapEventGetUserLocation();
  @override
  List<Object?> get props => [];
}

class MapEventSearchAddress extends MapEvent {
  final String searchedText;
  const MapEventSearchAddress({required this.searchedText});
  @override
  List<Object?> get props => [searchedText];
}

class MapEventActivityFilterToggled extends MapEvent {
  const MapEventActivityFilterToggled(this.filter);

  final ActivityStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

class MapEventAddressResultsCleared extends MapEvent {
  const MapEventAddressResultsCleared();
}
