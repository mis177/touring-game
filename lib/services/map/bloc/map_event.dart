import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapEventLoadMap extends MapEvent {
  final BuildContext context;
  const MapEventLoadMap({required this.context});
  @override
  List<Object?> get props => [];
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
  List<Object?> get props => [];
}
