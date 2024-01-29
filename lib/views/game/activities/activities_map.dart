import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/marker.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:touring_game/services/map/bloc/map_bloc.dart';
import 'package:touring_game/services/map/bloc/map_event.dart';
import 'package:touring_game/services/map/bloc/map_state.dart';
import 'package:touring_game/services/map/location_search_repo.dart';
import 'package:touring_game/utilities/map/activities_filter_button.dart';
import 'package:touring_game/utilities/map/flutter_map.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/map/get_markers.dart';

class ActivitiesMapProvider extends StatelessWidget {
  const ActivitiesMapProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(
          FirebaseCloudGameService(provider: FirebaseCloudGameProvider()),
          LocationSearchRepository()),
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
  List<AddressModel> searchResults = [];
  List<MyMarker> mapMarkers = [];
  CurrentLocationLayer locationLayer = CurrentLocationLayer();
  bool unfinishedActivitiesSort = false;

  bool finishedActivitiesSort = false;

  void refreshWidget() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapStateLoadingMarkers) {
          void reloadMarkers() {
            setState(() {
              mapMarkers = getMarkers(
                activities: state.activities,
                context: context,
                reloadMarkers: reloadMarkers,
              );
            });
          }

          mapMarkers = getMarkers(
            activities: state.activities,
            context: context,
            reloadMarkers: reloadMarkers,
          );
        }
        if (state is MapStateAddressSearchEnded) {
          searchResults = state.repo;
        }
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is MapStateUninitialized) {
          context.read<MapBloc>().add(
                MapEventLoadMap(context: context),
              );
        } else if (state is MapStateLoadedMap) {
          return Scaffold(
            body: Stack(
              children: [
                loadMap(
                  mapController: mapController,
                  currentLocation: state.currentLocation,
                  locationLayer: locationLayer,
                  mapMarkers: mapMarkers,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )),
                        onChanged: (value) {
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
                                      clickedThis: unfinishedActivitiesSort,
                                      clickedOther: finishedActivitiesSort,
                                      function: () {
                                        unfinishedActivitiesSort =
                                            !unfinishedActivitiesSort;
                                        if (unfinishedActivitiesSort) {
                                          finishedActivitiesSort = false;
                                        }
                                        context.read<MapBloc>().add(
                                              MapEventSearchActivitiesFinished(
                                                  finished: false,
                                                  activities: state.activities,
                                                  value:
                                                      unfinishedActivitiesSort),
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
                                      clickedThis: finishedActivitiesSort,
                                      clickedOther: unfinishedActivitiesSort,
                                      function: () {
                                        finishedActivitiesSort =
                                            !finishedActivitiesSort;
                                        if (finishedActivitiesSort) {
                                          unfinishedActivitiesSort = false;
                                        }
                                        context.read<MapBloc>().add(
                                              MapEventSearchActivitiesFinished(
                                                  finished: true,
                                                  activities: state.activities,
                                                  value:
                                                      finishedActivitiesSort),
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
                                if (searchResults.isNotEmpty) {
                                  setState(() {
                                    searchResults = [];
                                  });
                                }
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
                                    // return searchResultTile(
                                    //   mapController: mapController,
                                    //   searchResults: searchResults,
                                    //   index: index,
                                    //   function: () {
                                    //     setState(() {searchResults = [];});
                                    //   },
                                    // );
                                    return GestureDetector(
                                      onTap: () {
                                        mapController.move(
                                            lat_lng.LatLng(
                                                searchResults[index]
                                                    .coords
                                                    .latitude,
                                                searchResults[index]
                                                    .coords
                                                    .longitude),
                                            14);

                                        setState(() {
                                          searchResults = [];
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              Text(searchResults[index].name),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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
                      List<MyMarker> doneMarkers =
                          mapMarkers.where((element) => !element.done).toList();
                      var randomMarker = doneMarkers
                          .toList()[Random().nextInt(doneMarkers.length)];

                      mapController.move(
                          lat_lng.LatLng(randomMarker.point.latitude,
                              randomMarker.point.longitude),
                          18);

                      var markerButton = randomMarker.child as IconButton;
                      markerButton.onPressed!();
                    },
                    icon: const Icon(Icons.casino),
                  ),
                  IconButton(
                    iconSize: 40,
                    onPressed: () async {
                      context.read<MapBloc>().add(
                            const MapEventGetUserLocation(),
                          );
                      if (state.currentLocation != null) {
                        mapController.move(
                            lat_lng.LatLng(state.currentLocation!.latitude,
                                state.currentLocation!.longitude),
                            18);
                      }
                    },
                    icon: const Icon(Icons.my_location_rounded),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text(''));
      },
    );
  }
}
