import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/routes.dart';

class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  void reloadList() {
    setState(() {});
  }

  List<DatabasePlace> allPlaces = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }

        if (state is GameStateLoadedActivities) {
          context.read<GameBloc>().add(
                const GameEventLoadPlaces(),
              );
          Navigator.of(context).pushNamed(openActivitiesList, arguments: [
            state.activitiesList,
            reloadList,
          ]);
        }
      },
      builder: (context, state) {
        if (state is GameStateLoadedPlaces) {
          List<DatabaseActivity> doneActivities =
              state.activitiesList.where((element) => !element.isDone).toList();
          var random = Random();
          Set<DatabaseActivity> randomActivities = {};
          if (doneActivities.isNotEmpty) {
            for (var i = 0; i < 3; i++) {
              randomActivities
                  .add(doneActivities[random.nextInt(doneActivities.length)]);
            }
          }

          if (allPlaces.isEmpty) allPlaces = state.placesList;
          return Scaffold(
            backgroundColor: Colors.grey[300],
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: TextField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                    onChanged: (value) {
                      context.read<GameBloc>().add(
                            GameEventSearchPlaces(
                                text: value, places: allPlaces),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView.builder(
                        itemCount: state.placesList.length,
                        itemBuilder: (ctx, index) {
                          var placeActivities = state.activitiesList.where(
                              (element) =>
                                  element.placeId ==
                                  state.placesList[index].id);
                          return Card(
                              color: Colors.grey[100],
                              child: ListTile(
                                leading: const Icon(Icons.place_outlined),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.placesList[index].name,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${placeActivities.where((element) => element.isDone == true).length}/${placeActivities.length}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[900],
                                  ),
                                  child: const Icon(
                                    Icons.navigate_next_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  context.read<GameBloc>().add(
                                        GameEventLoadActivities(
                                            placeId:
                                                state.placesList[index].id),
                                      );
                                },
                              ));
                        }),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your random',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              Text(
                                'activities',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.run_circle,
                            size: 70,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: randomActivities.length,
                        itemBuilder: (ctx, index) {
                          return Card(
                            color: Colors.grey[100],
                            child: SizedBox(
                              width: 200,
                              child: Center(
                                child: ListTile(
                                  leading: const Icon(Icons.attractions),
                                  title: Text(
                                    randomActivities.elementAt(index).name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      "${randomActivities.elementAt(index).coords.latitude.toStringAsFixed(3)} ${randomActivities.elementAt(index).coords.longitude.toStringAsFixed(3)}"),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        openActivitityDetails,
                                        arguments: [
                                          randomActivities.elementAt(index),
                                          reloadList,
                                        ]);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            width: 10,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Text('');
        }
      },
    );
  }
}
