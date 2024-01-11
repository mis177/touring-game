import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';

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
    final activity =
        ModalRoute.of(context)!.settings.arguments as DatabaseActivity;
    bool isDone = activity.isDone;
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is GameStateUninitialized) {
          context.read<GameBloc>().add(
                GameEventLoadActivityDetails(activity: activity),
              );
          return const CircularProgressIndicator();
        } else if (state is GameStateLoadedActivityDetails) {
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Checkbox(
                          value: isDone,
                          onChanged: (bool? value) {
                            activity.isDone = value!;
                            isDone = !isDone;

                            context.read<GameBloc>().add(
                                  GameEventActivityDone(
                                      activity: activity,
                                      activityImage: state.activityImage),
                                );

                            setState(() {});
                          },
                        ),
                        Text(
                          activity.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text('0/2'),
                      ],
                    ),
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 10,
                      child: state.activityImage,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      activity.description,
                      textAlign: TextAlign.justify,
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.menu_book),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
