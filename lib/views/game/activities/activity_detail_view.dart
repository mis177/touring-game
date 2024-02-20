import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/routes.dart';

class ActivityDetailsBlocProvider extends StatelessWidget {
  const ActivityDetailsBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
          FirebaseCloudGameService(provider: FirebaseCloudGameProvider())),
      child: const ActivityDetailsView(),
    );
  }
}

class ActivityDetailsView extends StatefulWidget {
  const ActivityDetailsView({super.key});

  @override
  State<ActivityDetailsView> createState() => _ActivityDetailsViewState();
}

class _ActivityDetailsViewState extends State<ActivityDetailsView> {
  @override
  Widget build(BuildContext context) {
    final argumentList = ModalRoute.of(context)!.settings.arguments as List;
    final activity = argumentList[0];
    bool isDone = activity.isDone;
    Widget activityImage = const Icon(Icons.photo);
    return PopScope(
      onPopInvoked: (value) {
        argumentList[1]();
        if (argumentList.length > 2) {
          argumentList[2]();
        }
      },
      child: BlocConsumer<GameBloc, GameState>(listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      }, builder: (context, state) {
        if (state is GameStateUninitialized) {
          context.read<GameBloc>().add(
                GameEventLoadActivityDetails(activity: activity),
              );
          return const Text('');
        } else if (state is GameStateLoadedActivityDetails) {
          activityImage = state.activityImage;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              activity.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          activity.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Checkbox(
                          value: isDone,
                          onChanged: (bool? value) {
                            activity.isDone = value!;
                            isDone = !isDone;

                            context.read<GameBloc>().add(
                                  GameEventActivityDone(
                                      activity: activity,
                                      activityImage: activityImage),
                                );

                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: activityImage,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        activity.description,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(openUserNotes, arguments: [activity]);
            },
            child: const Icon(Icons.menu_book),
          ),
        );
      }),
    );
  }
}
