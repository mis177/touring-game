import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:touring_game/core/search_filters.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';

@immutable
sealed class MapState extends Equatable {
  final bool isLoading;
  final String? loadingText;
  final Exception? exception;
  const MapState({
    this.isLoading = false,
    this.loadingText = 'Please wait a moment',
    this.exception,
  });
  @override
  List<Object?> get props => [isLoading, loadingText, exception];
}

class MapStateUninitialized extends MapState {
  const MapStateUninitialized({super.isLoading});
}

class MapStateLoadingMap extends MapState {
  const MapStateLoadingMap({
    super.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class MapStateLoadedMap extends MapState {
  final List<DatabaseActivity> activities;
  final Coordinates? currentLocation;
  final List<AddressModel> searchResults;
  final ActivityStatusFilter? activityFilter;

  const MapStateLoadedMap({
    required this.activities,
    required this.currentLocation,
    required this.searchResults,
    required this.activityFilter,
    super.exception,
    super.isLoading,
    super.loadingText = null,
  });
  @override
  List<Object?> get props => [
    ...super.props,
    activities,
    currentLocation,
    searchResults,
    activityFilter,
  ];
}
