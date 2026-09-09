import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/core/search_filters.dart';
import 'package:touring_game/utilities/map/map_marker.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:touring_game/services/map/bloc/map_bloc.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/place_search_repository.dart';
import 'package:touring_game/utilities/map/activities_filter_button.dart';
import 'package:touring_game/utilities/map/flutter_map.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/dialogs/error_snack_bar.dart';
import 'package:touring_game/utilities/map/get_markers.dart';

class ActivitiesMapProvider extends StatelessWidget {
  const ActivitiesMapProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(
        gameRepository: context.read<CatalogRepository>(),
        searchRepository: context.read<PlaceSearchRepository>(),
        locationRepository: context.read<LocationRepository>(),
      ),
      child: const ActivitiesMap(),
    );
  }
}

class ActivitiesMap extends StatefulWidget {
  const ActivitiesMap({super.key});

  @override
  State<ActivitiesMap> createState() => _ActivitiesMapState();
}

class _ActivitiesMapState extends State<ActivitiesMap> {
  MapController mapController = MapController();
  TextEditingController addressSearchController = TextEditingController();
  CurrentLocationLayer locationLayer = CurrentLocationLayer();
  bool _centerOnUserLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapEventLoadMap());
  }

  @override
  void dispose() {
    addressSearchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapStateLoadedMap &&
            _centerOnUserLocation &&
            state.currentLocation != null) {
          _centerOnUserLocation = false;
          mapController.move(
            lat_lng.LatLng(
              state.currentLocation!.latitude,
              state.currentLocation!.longitude,
            ),
            18,
          );
        }
        if (state.exception != null) {
          showErrorSnackBar(context, state.exception!);
        }
      },
      builder: (context, state) {
        Coordinates? currentLocation;
        if (state is MapStateLoadedMap) {
          currentLocation = state.currentLocation;
        }
        final mapMarkers = state is MapStateLoadedMap
            ? getMarkers(
                activities: state.activities,
                context: context,
                onActivityChanged: (_) {
                  context.read<MapBloc>().add(const MapEventLoadMap());
                },
              )
            : <MyMarker>[];
        final searchResults = state is MapStateLoadedMap
            ? state.searchResults
            : const <AddressModel>[];
        final activityFilter = state is MapStateLoadedMap
            ? state.activityFilter
            : null;
        Widget Function(BuildContext, Widget, TileImage)? mapDarkTheme;
        if (Theme.of(context).brightness == Brightness.dark) {
          mapDarkTheme = darkModeTileBuilder;
        }
        return LoadingOverlay(
          isLoading: state.isLoading,
          text: state.loadingText ?? 'Please wait a moment',
          child: Scaffold(
            body: Stack(
              children: [
                loadMap(
                  mapController: mapController,
                  currentLocation: currentLocation,
                  locationLayer: locationLayer,
                  mapMarkers: mapMarkers,
                  darkMode: mapDarkTheme,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: addressSearchController,
                        onTapOutside: (event) {
                          addressSearchController.clear();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          context.read<MapBloc>().add(
                            MapEventSearchAddress(searchedText: value),
                          );
                        },
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: getFilterButton(
                                      clickedThis:
                                          activityFilter ==
                                          ActivityStatusFilter.unfinished,
                                      clickedOther:
                                          activityFilter ==
                                          ActivityStatusFilter.finished,
                                      function: () {
                                        context.read<MapBloc>().add(
                                          const MapEventActivityFilterToggled(
                                            ActivityStatusFilter.unfinished,
                                          ),
                                        );
                                      },
                                      text: 'Unfinished',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: getFilterButton(
                                      clickedThis:
                                          activityFilter ==
                                          ActivityStatusFilter.finished,
                                      clickedOther:
                                          activityFilter ==
                                          ActivityStatusFilter.unfinished,
                                      function: () {
                                        context.read<MapBloc>().add(
                                          const MapEventActivityFilterToggled(
                                            ActivityStatusFilter.finished,
                                          ),
                                        );
                                      },
                                      text: 'Finished',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TapRegion(
                              behavior: HitTestBehavior.opaque,
                              onTapOutside: (event) {
                                context.read<MapBloc>().add(
                                  const MapEventAddressResultsCleared(),
                                );
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 0,
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 3,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        mapController.move(
                                          lat_lng.LatLng(
                                            searchResults[index]
                                                .coords
                                                .latitude,
                                            searchResults[index]
                                                .coords
                                                .longitude,
                                          ),
                                          14,
                                        );

                                        context.read<MapBloc>().add(
                                          const MapEventAddressResultsCleared(),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondaryContainer,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            searchResults[index].name,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    iconSize: 40,
                    onPressed: () async {
                      List<MyMarker> doneMarkers = mapMarkers
                          .where((element) => !element.done)
                          .toList();
                      if (doneMarkers.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No unfinished activities available.',
                            ),
                          ),
                        );
                        return;
                      }
                      var randomMarker = doneMarkers
                          .toList()[Random().nextInt(doneMarkers.length)];

                      mapController.move(
                        lat_lng.LatLng(
                          randomMarker.point.latitude,
                          randomMarker.point.longitude,
                        ),
                        18,
                      );

                      var markerButton = randomMarker.child as IconButton;
                      markerButton.onPressed!();
                    },
                    icon: const Icon(Icons.casino),
                  ),
                  IconButton(
                    iconSize: 40,
                    onPressed: () async {
                      _centerOnUserLocation = true;
                      context.read<MapBloc>().add(
                        const MapEventGetUserLocation(),
                      );
                    },
                    icon: const Icon(Icons.my_location_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
