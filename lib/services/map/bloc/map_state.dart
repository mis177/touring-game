import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';

@immutable
sealed class MapState extends Equatable {
  final bool isLoading;
  final String? loadingText;
  const MapState({
    this.isLoading = false,
    this.loadingText = 'Please wait a moment',
  });
  @override
  List<Object?> get props => [];
}

class MapStateUninitialized extends MapState {
  const MapStateUninitialized({super.isLoading});
}

class MapStateLoadingMap extends MapState {
  final Exception? exception;
  const MapStateLoadingMap({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class MapStateLoadedMap extends MapState {
  final List<DatabaseActivity> activities;
  final Position? currentLocation;
  final List<AddressModel> searchResults;

  const MapStateLoadedMap({
    required this.activities,
    required this.currentLocation,
    required this.searchResults,
  });
  @override
  List<Object?> get props => [searchResults];
}

class MapStateMarkerClicked extends MapState {
  const MapStateMarkerClicked();
}

class MapStateSearchingAddress extends MapState {
  final Exception? exception;
  const MapStateSearchingAddress({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class MapStateAddressSearchEnded extends MapState {
  final List<AddressModel> repo;
  const MapStateAddressSearchEnded({required this.repo});
  @override
  List<Object?> get props => [repo];
}

class MapStateGettingUserLocation extends MapState {
  const MapStateGettingUserLocation();
}

class MapStateLoadingMarkers extends MapState {
  final List<DatabaseActivity> activities;
  const MapStateLoadingMarkers({
    required this.activities,
    super.isLoading,
    super.loadingText = null,
  });
}
