import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (allPlaces.isEmpty) allPlaces = state.placesList;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Scaffold(
              body: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
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
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: state.placesList.length,
                        itemBuilder: (ctx, index) {
                          var placeActivities = state.activitiesList.where(
                              (element) =>
                                  element.placeId ==
                                  state.placesList[index].id);
                          return Card(
                              child: ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              state.placesList[index].name,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                                '${placeActivities.where((element) => element.isDone == true).length}/${placeActivities.length}'),
                            onTap: () {
                              context.read<GameBloc>().add(
                                    GameEventLoadActivities(
                                        placeId: state.placesList[index].id),
                                  );
                            },
                          ));
                        }),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('');
        }
      },
    );
  }
}
