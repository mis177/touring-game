import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/map/activities_filter_button.dart';
import 'package:touring_game/utilities/routes.dart';

class ActivitiesListBlocProvider extends StatelessWidget {
  const ActivitiesListBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
          FirebaseCloudGameService(provider: FirebaseCloudGameProvider())),
      child: const ActivitiesList(),
    );
  }
}

class ActivitiesList extends StatefulWidget {
  const ActivitiesList({super.key});

  @override
  State<ActivitiesList> createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {
  List<DatabaseActivity> filteredActivities = [];
  bool unfinishedActivitiesSort = false;
  bool finishedActivitiesSort = false;

  void reloadList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final argumentList = ModalRoute.of(context)!.settings.arguments as List;
    final activities = argumentList[0];
    filteredActivities = activities;
    return BlocConsumer<GameBloc, GameState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment');
      } else {
        LoadingScreen().hide();
      }

      if (state is GameStateLoadedActivities) {
        filteredActivities = state.activitiesList;
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Activities list',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onChanged: (value) {
                  context.read<GameBloc>().add(
                        GameEventSearchActivitiesText(
                            text: value, activities: activities),
                      );
                },
              ),
              const SizedBox(height: 10),
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
                          unfinishedActivitiesSort = !unfinishedActivitiesSort;
                          if (unfinishedActivitiesSort) {
                            finishedActivitiesSort = false;
                          }
                          context.read<GameBloc>().add(
                                GameEventSearchActivitiesFinished(
                                    finished: false,
                                    activities: activities,
                                    value: unfinishedActivitiesSort),
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
                          finishedActivitiesSort = !finishedActivitiesSort;
                          if (finishedActivitiesSort) {
                            unfinishedActivitiesSort = false;
                          }
                          context.read<GameBloc>().add(
                                GameEventSearchActivitiesFinished(
                                    finished: true,
                                    activities: activities,
                                    value: finishedActivitiesSort),
                              );
                        },
                        text: 'Finished',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (ctx, index) {
                      Color activityColor =
                          Theme.of(context).colorScheme.onSurface;
                      if (filteredActivities[index].isDone) {
                        activityColor = Colors.green;
                      }
                      return Card(
                          shadowColor: activityColor,
                          child: ListTile(
                            leading: const Icon(Icons.attractions),
                            title: Text(
                              style: TextStyle(color: activityColor),
                              filteredActivities[index].name,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(openActivitityDetails, arguments: [
                                filteredActivities[index],
                                reloadList,
                                argumentList[1],
                              ]);
                            },
                          ));
                    }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
